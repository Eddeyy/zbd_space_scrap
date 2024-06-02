CREATE OR REPLACE FUNCTION SUPERVISOR_LOOP()
RETURNS VOID
LANGUAGE 'plpgsql'
AS $FUNCTION$
DECLARE

    v_ship_id               INTEGER;
    v_expedition_record     RECORD;

BEGIN

    RAISE NOTICE 'CHECKING FOR PENDING EXPEDITIONS...';

    FOR v_ship_id IN SELECT ID FROM SHIP
    LOOP
    
        RAISE NOTICE 'LOOKING AT SHIP %...', v_ship_id;

        CONTINUE WHEN EXISTS (
            SELECT 1 FROM EXPEDITION
            WHERE SHIPID = v_ship_id AND DATEOFDEPARTURE IS NOT NULL AND DATEOFRETURN IS NULL
        );

        SELECT * INTO v_expedition_record
        FROM EXPEDITION
        WHERE SHIPID = v_ship_id AND DATEOFDEPARTURE IS NULL
        ORDER BY ID
        LIMIT 1;

        IF FOUND THEN
            RAISE NOTICE 'STARTING SHIP %...', v_ship_id;
            UPDATE EXPEDITION SET DATEOFDEPARTURE=CURRENT_DATE WHERE ID = v_expedition_record.id;
            PERFORM start_ship_flight(v_ship_id, v_expedition_record.MOONNAME);
        END IF;

    END LOOP;
END
$FUNCTION$;

SELECT cron.schedule('expedition-supervisor', '5 seconds', 'SELECT * FROM SUPERVISOR_LOOP()');