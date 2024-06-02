CREATE OR REPLACE TRIGGER engine_kaput_trigger
AFTER UPDATE OF fuel ON ship
FOR EACH ROW
EXECUTE FUNCTION update_engine_status();

CREATE OR REPLACE TRIGGER engine_power_update_trigger
BEFORE UPDATE OF power ON ship_engine
FOR EACH ROW
EXECUTE FUNCTION round_engine_power();

CREATE OR REPLACE TRIGGER finish_expedition_trigger
AFTER DELETE ON Excavation_Event
FOR EACH ROW
EXECUTE FUNCTION finish_expedition(); 

SELECT cron.schedule('weather-update', '* * * * *', 'SELECT * FROM change_weather()');