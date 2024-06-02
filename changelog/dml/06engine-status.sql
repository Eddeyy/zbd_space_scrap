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

CREATE OR REPLACE FUNCTION round_engine_power()
RETURNS TRIGGER
LANGUAGE 'plpgsql'
AS $FUNCTION$
BEGIN
    IF NEW.power > 1.0 THEN
        NEW.power := 1.0;
    END IF;
    IF NEW.power < 0.0 THEN
        NEW.power := 0.0;
    END IF;
    RETURN NEW;
END;
$FUNCTION$;