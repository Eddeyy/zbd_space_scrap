CREATE OR REPLACE FUNCTION create_expedition(employee_id BIGINT, moon_name VARCHAR(32))
RETURNS BOOLEAN
LANGUAGE 'plpgsql'
AS $FUNCTION$
DECLARE
  v_ship_id INTEGER;
BEGIN
  IF NOT is_employee_decisive(employee_id) THEN
    RETURN FALSE;
  END IF;

  SELECT ShipID INTO v_ship_id FROM Employee WHERE ID = employee_id;
  RAISE NOTICE 'ship id - %', v_ship_id;
  IF v_ship_id IS NULL THEN
    RAISE NOTICE 'v_ship_id is null';
    RETURN FALSE;
  END IF;

  INSERT INTO Expedition (ShipID, MoonName) VALUES (v_ship_id, moon_name);

  RETURN TRUE;
END
$FUNCTION$;

CREATE OR REPLACE FUNCTION is_employee_decisive(employee_id BIGINT)
RETURNS BOOLEAN
LANGUAGE 'plpgsql'
AS $FUNCTION$
DECLARE
  v_employee_min_score BIGINT;
  v_req_sc BIGINT;

  v_same_ship_empl_min_score BIGINT;
  v_ship_id BIGINT;
BEGIN
  SELECT r.Requiredscore 
  INTO v_employee_min_score 
  FROM Rank r 
  JOIN Employee e ON r.RankName = e.Rank 
  WHERE e.ID = employee_id;

  RAISE NOTICE 'v_emplyee min score %', v_employee_min_score;
  
  SELECT Requiredscore 
  INTO v_req_sc 
  FROM Rank 
  WHERE Rankname = 'Employee';

  RAISE NOTICE 'req sc %', v_req_sc;

  IF v_employee_min_score < v_req_sc THEN
    RETURN FALSE;
  END IF;

  SELECT shipid INTO v_ship_id FROM Employee WHERE id = employee_id;
  RAISE NOTICE 'inside decision: %', v_ship_id;

  FOR v_same_ship_empl_min_score IN 
    SELECT r.requiredscore 
    FROM rank r 
    JOIN Employee e ON r.RankName = e.Rank 
    WHERE ShipID = v_ship_id
  LOOP
    RAISE NOTICE 'ship id %', v_ship_id;
    IF v_employee_min_score < v_same_ship_empl_min_score THEN
      RETURN FALSE;
    END IF;
  END LOOP;

  RETURN TRUE;
END
$FUNCTION$;


CREATE OR REPLACE FUNCTION finish_expedition()
RETURNS TRIGGER
LANGUAGE 'plpgsql'
AS $FUNCTION$
BEGIN
  UPDATE Expedition 
  SET DateOfReturn = CURRENT_DATE
  WHERE ID = OLD.ExpeditionID;

  UPDATE EMPLOYEE
  SET HEALTH = 100,
      HEARTRATE = 90
  WHERE
      ID = OLD.EMPLOYEEID;

  RETURN OLD;
END
$FUNCTION$;

CREATE OR REPLACE FUNCTION recalculate_exp()
RETURNS TRIGGER
LANGUAGE 'plpgsql'
AS $FUNCTION$
DECLARE
  c_employee      CURSOR FOR SELECT em.ID
                              FROM Employee em 
                              JOIN Expedition ex 
                              ON ex.ShipID = em.ShipID
                              WHERE ex.ID = OLD.ID; 
  c_scrap         REFCURSOR;

  v_employee_id   BIGINT;
  v_scrap_row     RECORD;

  v_new_exp_value int8;
  v_danger_level  int4;

  v_employee_exp  int8;
  v_new_rank      varchar(32);
BEGIN
  OPEN c_employee;
  LOOP
    FETCH c_employee INTO v_employee_id;
    EXIT WHEN NOT FOUND;
    
    v_new_exp_value := 0;
    OPEN c_scrap FOR SELECT * 
                     FROM Scrap 
                     WHERE EmployeeID = v_employee_id;
    LOOP
      FETCH c_scrap INTO v_scrap_row;
      EXIT WHEN NOT FOUND;
      
      SELECT DangerLevel 
      INTO v_danger_level 
      FROM Moon 
      WHERE name = v_scrap_row.MoonName;
      
      v_new_exp_value := v_new_exp_value + (v_scrap_row.Value/2)::int8 + (v_danger_level/5)::int8;
    END LOOP;
    CLOSE c_scrap;

    UPDATE Employee 
    SET Experience = v_new_exp_value 
    WHERE ID = v_employee_id;
   
  END LOOP;
  CLOSE c_employee;

  OPEN c_employee;
  LOOP
    FETCH c_employee INTO v_employee_id;
    EXIT WHEN NOT FOUND;

    SELECT Experience 
    INTO v_employee_exp 
    FROM Employee 
    WHERE ID = v_employee_id;

    SELECT RankName
    INTO v_new_rank
    FROM Rank 
    WHERE RequiredScore < v_employee_exp
    ORDER BY RequiredScore DESC
    LIMIT 1;

    UPDATE Employee 
    SET Rank = v_new_rank
    WHERE ID = v_employee_id;

  END LOOP;
  CLOSE c_employee;
  RETURN OLD;
END
$FUNCTION$;