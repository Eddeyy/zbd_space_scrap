DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'scrap_type') THEN
    EXECUTE 'DROP TYPE scrap_type';
  END IF;

  EXECUTE '
  CREATE TYPE scrap_type AS (
    Name          varchar(32),     
    Weight        numeric(10, 2), 
    Value         numeric(8, 2),  
    Volume        int4,           
    ShipID        int8,           
    EmployeeID    int8,
    ExpeditionID  int8,                  
    MoonName      varchar(32)    
  )';
END $$;

CREATE OR REPLACE FUNCTION generate_scrap_for_employee(employee_id BIGINT)
RETURNS VOID
LANGUAGE 'plpgsql'
AS $FUNCTION$
DECLARE
  v_generated_scrap       scrap_type;

  v_material_count        INTEGER;
  v_material_name         varchar(16);

  c_chosen_material       REFCURSOR;
  v_chosen_material_row   RECORD;
  
  v_vol                   int4;

  v_ship_load             numeric(10, 2);
  v_ship_max_load         numeric(10, 2);
  v_ship_volume           numeric(10, 2);
  v_ship_max_volume       numeric(10, 2);
BEGIN
  SELECT Name 
  INTO v_generated_scrap.Name 
  FROM Scrap_Name 
  ORDER BY RANDOM() 
  LIMIT 1;

  v_generated_scrap.Weight := 0;
  v_generated_scrap.Value := 0;
  v_generated_scrap.Volume := 0;

  CREATE TEMP TABLE chosen_material (
    Name    varchar(16),
    Volume  int4,
    Weight  numeric(10, 2)
  );

  v_material_count := floor(random() * 3) + 1;

  FOR i IN 1..v_material_count LOOP
    SELECT Name
    INTO v_material_name
    FROM Material
    ORDER BY RANDOM()
    LIMIT 1;

    v_vol := ceil(random() * 10);
    INSERT INTO chosen_material (Name, Volume, Weight) 
    VALUES (v_material_name, v_vol, v_vol * (SELECT density 
                                            FROM material 
                                            WHERE name = v_material_name 
                                            LIMIT 1));
  END LOOP;

  OPEN c_chosen_material FOR SELECT * FROM chosen_material;
  LOOP
    FETCH c_chosen_material INTO v_chosen_material_row;
    EXIT WHEN NOT FOUND;
    
    v_generated_scrap.Weight := v_generated_scrap.Weight + v_chosen_material_row.Weight;
    v_generated_scrap.Volume := v_generated_scrap.Volume + v_chosen_material_row.Volume;
    v_generated_scrap.Value := v_chosen_material_row.Weight * (SELECT value FROM material Where name = v_chosen_material_row.name LIMIT 1);
      
  END LOOP;
  CLOSE c_chosen_material;


  v_generated_scrap.EmployeeID := employee_id;
  SELECT ex.ID, ex.MoonName
    FROM Expedition ex
    INTO v_generated_scrap.ExpeditionID, v_generated_scrap.MoonName
    JOIN Ship sh ON sh.ID = ex.ShipID
    JOIN Employee em ON em.ShipID = sh.ID
    WHERE em.ID = employee_id
    AND ex.DateOfDeparture IS NOT NULL
    AND ex.DateOfReturn IS NULL;

  SELECT ShipID 
  INTO v_generated_scrap.ShipID
  FROM Employee 
  WHERE Employee.id = employee_id;

  SELECT MaxLoad, Load, MaxVolume, Volume 
  INTO v_ship_max_load, v_ship_load, v_ship_max_volume, v_ship_volume
  WHERE ID = v_generated_scrap.ShipID;

  IF v_generated_scrap.Weight + v_ship_load > v_ship_max_load OR
      v_generated_scrap.Volume + v_ship_volume > v_ship_max_volume THEN
    RETURN;
  END IF;

  INSERT INTO Scrap (name, 
                    weight, 
                    value, 
                    volume, 
                    shipid, 
                    employeeid, 
                    expeditionid, 
                    moonname) 
  VALUES (v_generated_scrap.name,
          v_generated_scrap.weight,
          v_generated_scrap.value,
          v_generated_scrap.volume,
          v_generated_scrap.shipid,
          v_generated_scrap.employeeid,
          v_generated_scrap.expeditionid,
          v_generated_scrap.moonname);

  OPEN c_chosen_material FOR SELECT * FROM chosen_material;
  LOOP
    FETCH c_chosen_material INTO v_chosen_material_row;
    EXIT WHEN NOT FOUND;
    
    INSERT INTO Material_Scrap (MaterialName, 
                               ScrapID) 
    VALUES (v_chosen_material_row.Name, 
            (SELECT max(ID) FROM Scrap));
    
  END LOOP;
  CLOSE c_chosen_material;

  DROP TABLE chosen_material;
END
$FUNCTION$;

CREATE OR REPLACE FUNCTION put_employee_in_danger(employee_id BIGINT)
RETURNS VOID
LANGUAGE 'plpgsql'
AS $FUNCTION$  
DECLARE
    v_damage_value  INTEGER;
BEGIN
  v_damage_value := ceil(random() * (20-10+1)+10)::INT;
  UPDATE Employee
  SET heartrate = 
    CASE 
      WHEN heartrate + 20 < 200 AND heartrate > 0 
        THEN heartrate + 20 
        ELSE 0 
    END,
  HEALTH = 
    CASE 
      WHEN HEARTRATE + 20 > 200 THEN 0
      WHEN ceil(random() * 100 + 1)::INT < 30 THEN 
        CASE 
          WHEN HEALTH - v_damage_value > 0 THEN HEALTH - v_damage_value
          ELSE 0
        END
      ELSE HEALTH
    END
  WHERE ID = employee_id;
END
$FUNCTION$;

CREATE OR REPLACE FUNCTION total_scrap()
RETURNS TRIGGER
LANGUAGE 'plpgsql'
AS $FUNCTION$
BEGIN
    UPDATE EXPEDITION
    SET totalScrap = totalScrap + NEW.VALUE
    WHERE ID = NEW.EXPEDITIONID;
  RETURN NEW;
END;
$FUNCTION$;