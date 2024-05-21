CREATE EXTENSION pg_cron;
GRANT usage ON SCHEMA cron TO postgres;
GRANT all privileges ON all tables IN SCHEMA cron TO postgres;