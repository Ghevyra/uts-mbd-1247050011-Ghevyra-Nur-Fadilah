CREATE USER backend_dev   WITH PASSWORD 'backend_dev123';
CREATE USER bi_dev        WITH PASSWORD 'bi_dev123';
CREATE USER data_engineer WITH PASSWORD 'data_engineer123';

GRANT CONNECT ON DATABASE postgres TO backend_dev, bi_dev, data_engineer;

-- data_engineer: CREATE, MODIFY, DROP semua objek + CRUD semua tabel
-- (ALTER/DROP butuh kepemilikan, jadi data_engineer dijadikan owner schema salam)
GRANT CREATE ON DATABASE postgres TO data_engineer;
ALTER SCHEMA salam OWNER TO data_engineer;

DO $$
DECLARE r record;
BEGIN
    FOR r IN SELECT tablename FROM pg_tables WHERE schemaname = 'salam' LOOP
        EXECUTE format('ALTER TABLE salam.%I OWNER TO data_engineer', r.tablename);
    END LOOP;
    FOR r IN SELECT viewname FROM pg_views WHERE schemaname = 'salam' LOOP
        EXECUTE format('ALTER VIEW salam.%I OWNER TO data_engineer', r.viewname);
    END LOOP;
    FOR r IN SELECT p.oid::regprocedure::text AS sig
             FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
             WHERE n.nspname = 'salam' LOOP
        EXECUTE 'ALTER FUNCTION ' || r.sig || ' OWNER TO data_engineer';
    END LOOP;
END $$;

-- backend_dev: CRUD semua tabel
GRANT USAGE ON SCHEMA salam TO backend_dev;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA salam TO backend_dev;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA salam TO backend_dev;


-- bi_dev: hanya SELECT semua tabel/view
GRANT USAGE ON SCHEMA salam TO bi_dev;
GRANT SELECT ON ALL TABLES IN SCHEMA salam TO bi_dev;

-- Tabel baru buatan data_engineer otomatis ikut aturan yang sama
ALTER DEFAULT PRIVILEGES FOR ROLE data_engineer IN SCHEMA salam
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO backend_dev;
ALTER DEFAULT PRIVILEGES FOR ROLE data_engineer IN SCHEMA salam
    GRANT USAGE, SELECT ON SEQUENCES TO backend_dev;
ALTER DEFAULT PRIVILEGES FOR ROLE data_engineer IN SCHEMA salam
    GRANT SELECT ON TABLES TO bi_dev;