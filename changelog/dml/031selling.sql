CREATE OR REPLACE FUNCTION start_selling(ship_id BIGINT)
RETURNS VOID
LANGUAGE 'plpgsql'
AS $FUNCTION$
DECLARE
  c_employee_id   CURSOR FOR SELECT ID FROM Employee WHERE ShipID = ship_id;
  v_emp_id        BIGINT;
BEGIN
  OPEN c_employee_id;
  LOOP
    FETCH c_employee_id INTO v_emp_id;
    EXIT WHEN NOT FOUND;

    PERFORM cron.schedule(format('employee-%s-selling', v_emp_id), '5 seconds', format('SELECT sell(%s)', v_emp_id));
  END LOOP;
END
$FUNCTION$;

CREATE OR REPLACE FUNCTION sell(employee_id BIGINT)
RETURNS BOOLEAN
LANGUAGE 'plpgsql'
AS $FUNCTION$
DECLARE
  v_ship_id INTEGER;
  v_expedition_id INTEGER;
  v_scrap_id INTEGER;
BEGIN
  SELECT ShipID 
  INTO v_ship_id 
  FROM Employee 
  WHERE ID = employee_id;

  SELECT ID 
  INTO v_scrap_id 
  FROM Scrap
  WHERE ShipID = v_ship_id 
  LIMIT 1;

  RAISE NOTICE 'selling'; 

  IF v_scrap_id IS NULL THEN
    PERFORM cron.unschedule(format('employee-%s-selling', employee_id));
    RAISE NOTICE 'no more scrap';
    SELECT ID 
    INTO v_expedition_id 
    FROM Expedition
    WHERE ShipID = v_ship_id 
    AND DateOfDeparture IS NOT NULL 
    AND DateOfReturn IS NULL;

    UPDATE Expedition
    SET DateOfReturn = CURRENT_DATE
    WHERE ID = v_expedition_id;
    RETURN FALSE;
  END IF;
  
  UPDATE Scrap
  SET ShipID = NULL
  WHERE ID = v_scrap_id;
  RETURN TRUE;
END
$FUNCTION$;