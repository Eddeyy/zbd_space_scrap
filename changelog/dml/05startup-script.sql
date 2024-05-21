CREATE TRIGGER engine_kaput_trigger
AFTER UPDATE OF fuel ON ship
FOR EACH ROW
EXECUTE FUNCTION update_engine_status();

SELECT cron.schedule('weather-update', '* * * * *', 'SELECT * FROM change_weather()');