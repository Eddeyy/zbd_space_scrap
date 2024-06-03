CREATE OR REPLACE FUNCTION update_expedition_status(expedition_id BIGINT)
RETURNS BOOLEAN
LANGUAGE 'plpgsql'
AS $FUNCTION$
DECLARE
  v_event_sum INTEGER;
  v_event_count INTEGER;
BEGIN

  SELECT sum(EventCount) 
  INTO v_event_sum
  FROM Excavation_Event ee
  JOIN Expedition ex ON ex.ID = ee.ExpeditionID
  WHERE ex.ShipID = expedition_id;

  SELECT count(*) 
  INTO v_event_count
  FROM Excavation_Event
  WHERE ExpeditionID = expedition_id;

  IF v_event_count = 0 THEN
    RETURN TRUE;
  END IF;

  IF v_event_sum < 8 * v_event_count THEN
    RETURN FALSE;
  END IF;

  RETURN TRUE;
END
$FUNCTION$;


CREATE OR REPLACE FUNCTION excavate(employee_id BIGINT)
RETURNS BOOLEAN
LANGUAGE 'plpgsql'
AS $FUNCTION$
DECLARE
  v_event   INTEGER;
  v_ship_id INTEGER;
  v_event_count INTEGER;
  v_expedition_id INTEGER;
BEGIN
  SELECT ShipID 
  INTO v_ship_id 
  FROM Employee 
  WHERE ID = employee_id;

  SELECT ID 
  INTO v_expedition_id 
  FROM Expedition
  WHERE ShipID = v_ship_id 
  AND DateOfDeparture IS NOT NULL
  AND DateOfReturn IS NULL;

  SELECT EventCount
  INTO v_event_count 
  FROM Excavation_Event 
  WHERE ExpeditionID = v_expedition_id 
  AND EmployeeID = employee_id;

  IF v_event_count IS NULL OR v_event_count > 7 OR v_expedition_id IS NULL THEN
    PERFORM cron.unschedule(format('employee-%s-excavation', employee_id));

    IF update_expedition_status(v_expedition_id) THEN
      DELETE FROM Excavation_Event WHERE ExpeditionID = v_expedition_id;
    END IF;

    RETURN TRUE;
  END IF;

  IF (SELECT HEALTH FROM Employee WHERE ID = employee_id) = 0 THEN
    RAISE NOTICE '% is dead', (SELECT SURNAME FROM EMPLOYEE WHERE ID = employee_id LIMIT 1);
    PERFORM cron.unschedule(format('employee-%s-excavation', employee_id));
    RETURN FALSE;
  END IF;

  UPDATE Excavation_Event
  SET EventCount = EventCount + 1
  WHERE EmployeeID = employee_id
  AND ExpeditionID = v_expedition_id;

  v_event := floor(random() * 3);

  IF v_event = 0 THEN
    RAISE NOTICE '% found scrap', (SELECT SURNAME FROM EMPLOYEE WHERE ID = employee_id LIMIT 1);
    PERFORM generate_scrap_for_employee(employee_id);
  ELSE 
    RAISE NOTICE '% did nothing!!', (SELECT SURNAME FROM EMPLOYEE WHERE ID = employee_id LIMIT 1);
  END IF;

  IF floor(random() * (100+1))::int < 
      (SELECT MAX(m.dangerlevel) 
      FROM moon m 
      INNER JOIN expedition e ON e.moonname = m.name 
      WHERE e.id = v_expedition_id) THEN

    RAISE NOTICE '% was put in danger', (SELECT SURNAME FROM EMPLOYEE WHERE ID = employee_id LIMIT 1);
    PERFORM put_employee_in_danger(employee_id);
    
  END IF;
  RETURN TRUE;
END
$FUNCTION$;


CREATE OR REPLACE FUNCTION start_excavation(ship_id BIGINT)
RETURNS VOID
LANGUAGE 'plpgsql'
AS $FUNCTION$
DECLARE
  c_employee_id   CURSOR FOR SELECT ID FROM Employee WHERE ShipID = ship_id;
  v_emp_id        BIGINT;
  v_expedition_id BIGINT;
BEGIN

  SELECT id
  INTO v_expedition_id 
  FROM Expedition
  WHERE ShipID = ship_id
  AND DateOfDeparture IS NOT NULL AND DateOfReturn IS NULL;

  OPEN c_employee_id;
  LOOP
    FETCH c_employee_id INTO v_emp_id;
    EXIT WHEN NOT FOUND;

    INSERT INTO Excavation_Event (ExpeditionID,
                                  EmployeeID, 
                                  EventCount)
    VALUES (v_expedition_id,
            v_emp_id,
            1);
    PERFORM cron.schedule(format('employee-%s-excavation', v_emp_id), '5 seconds', format('SELECT excavate(%s)', v_emp_id));
  END LOOP;
END
$FUNCTION$;
