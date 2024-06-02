CREATE OR REPLACE FUNCTION update_engine_status()
RETURNS TRIGGER
LANGUAGE 'plpgsql'
AS $FUNCTION$
BEGIN
    IF(ceil(random() * 100) - 1 > 0) THEN
        RETURN NEW;
    END IF;
    
    UPDATE ship_engine
    SET state = 'Stopped'
    WHERE shipid = NEW.id;

    return NEW;
END;
$FUNCTION$;