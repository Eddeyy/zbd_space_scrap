CREATE OR REPLACE FUNCTION change_weather()
RETURNS void
LANGUAGE 'plpgsql'
AS $FUNCTION$
DECLARE
    v_moon_row RECORD;
    v_weather_row RECORD;
    v_weather_id INTEGER;
    t_weather_names TEXT[];

BEGIN
    FOR v_moon_row IN SELECT * FROM moon LOOP
        v_weather_id := ceil(random() * 4);
        SELECT * INTO v_weather_row FROM weather OFFSET v_weather_id-1 LIMIT 1;
        RAISE NOTICE 'v_weather_row.weathername: %', v_weather_row.weathername;

        UPDATE moon 
        SET weather = v_weather_row.weathername 
        WHERE name = v_moon_row.name;
    END LOOP;
END
$FUNCTION$
