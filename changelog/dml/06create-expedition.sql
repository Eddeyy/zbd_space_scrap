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

  INSERT INTO Expedition (DateOfDeparture, ShipID, MoonName) VALUES (CURRENT_DATE, v_ship_id, moon_name);
  PERFORM start_ship_flight(v_ship_id, moon_name);

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
