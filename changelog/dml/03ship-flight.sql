CREATE OR REPLACE FUNCTION fly_ship_in_direction_of(ship_id BIGINT, moon_name VARCHAR(32))
RETURNS void 
LANGUAGE 'plpgsql'
AS $FUNCTION$
DECLARE
    v_ship_row RECORD;
    v_moon_row RECORD;
    v_engine_status VARCHAR(32);

    c_ship_velocity DOUBLE PRECISION := 200;
    c_fuel_consumption INTEGER := 1;

    v_ship_load INTEGER;

    v_rev_sqrt_of_vec DOUBLE PRECISION;
    
    x_dist DOUBLE PRECISION;
    y_dist DOUBLE PRECISION;
    z_dist DOUBLE PRECISION;

    x_unit_vec DOUBLE PRECISION;
    y_unit_vec DOUBLE PRECISION;
    z_unit_vec DOUBLE PRECISION;

BEGIN
    SELECT * INTO v_ship_row FROM ship WHERE id = ship_id;
    SELECT * INTO v_moon_row FROM moon WHERE name = moon_name;
    SELECT load INTO v_ship_load FROM ship WHERE id = ship_id;

    x_dist := v_moon_row.coordx - v_ship_row.coordx;
    y_dist := v_moon_row.coordy - v_ship_row.coordy;
    z_dist := v_moon_row.coordz - v_ship_row.coordz;

    IF ABS(x_dist) < 201 AND ABS(y_dist) < 201 AND ABS(z_dist) < 201 THEN
        UPDATE ship
        SET coordx = v_moon_row.coordx,
            coordy = v_moon_row.coordy,
            coordz = v_moon_row.coordz
        WHERE id = ship_id;
        PERFORM cron.unschedule(format('ship-%s-flight', ship_id));
        
    END IF;

    IF v_ship_row.fuel < (c_fuel_consumption * v_ship_load/10) THEN
        RETURN;
    END IF;

    FOR v_engine_status IN SELECT state FROM ship_engine WHERE shipid = ship_id LOOP 
        IF v_engine_status != 'Working' THEN
            RETURN;
        END IF;
    END LOOP; 

    v_rev_sqrt_of_vec = 1/SQRT(x_dist*x_dist + y_dist*y_dist + y_dist*y_dist);

    x_unit_vec := v_rev_sqrt_of_vec*x_dist;
    y_unit_vec := v_rev_sqrt_of_vec*y_dist;
    z_unit_vec := v_rev_sqrt_of_vec*z_dist;

    UPDATE ship
    SET coordx = coordx + (c_ship_velocity * x_unit_vec),
        coordy = coordy + (c_ship_velocity * y_unit_vec),
        coordz = coordz + (c_ship_velocity * z_unit_vec),
        fuel = fuel - (c_fuel_consumption * v_ship_load/10)
    WHERE id = ship_id;
END
$FUNCTION$;



CREATE OR REPLACE FUNCTION start_ship_flight(ship_id BIGINT, moon_name VARCHAR(32))
RETURNS BOOLEAN
LANGUAGE 'plpgsql'
AS $FUNCTION$
DECLARE
    v_ship_row RECORD;
    v_a INTEGER;
    v_b INTEGER;
BEGIN
    PERFORM 1 FROM ship WHERE id = ship_id;

    IF NOT FOUND THEN
        RAISE NOTICE 'ship not found';
        RETURN FALSE;
    END IF;

    PERFORM cron.schedule(format('ship-%s-flight', ship_id), '* * * * *', format('SELECT * FROM fly_ship_in_direction_of(%s, ''%s'')', ship_id, moon_name));
    RETURN TRUE;
END
$FUNCTION$;
