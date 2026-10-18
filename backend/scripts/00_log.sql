set search_path to "prbd-2526-f02", public;
ALTER SYSTEM SET logging_collector = 'on';
ALTER SYSTEM SET log_statement = 'all';
SELECT pg_reload_conf();

--SELECT pg_current_logfile();