-- ========================================
-- Create application schema
-- ========================================
CREATE SCHEMA IF NOT EXISTS voyage_bot;

-- ========================================
-- Revoke public access
-- ========================================
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM PUBLIC;

-- ========================================
-- Create roles
-- ========================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'voyage_bot_app') THEN
        CREATE ROLE voyage_bot_app;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'voyage_bot_migrate') THEN
        CREATE ROLE voyage_bot_migrate;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'voyage_bot_read_only') THEN
        CREATE ROLE voyage_bot_read_only;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'voyage_bot_admin') THEN
        CREATE ROLE voyage_bot_admin;
    END IF;
END 
$$;

-- ========================================
-- Schema permissions
-- ========================================

-- App role
GRANT USAGE ON SCHEMA voyage_bot TO voyage_bot_app;

GRANT SELECT, INSERT, UPDATE, DELETE
    ON ALL TABLES IN SCHEMA voyage_bot
    TO voyage_bot_app;

ALTER DEFAULT PRIVILEGES IN SCHEMA voyage_bot
    GRANT SELECT, INSERT, UPDATE, DELETE
    ON TABLES TO voyage_bot_app;

ALTER DEFAULT PRIVILEGES IN SCHEMA voyage_bot
    GRANT USAGE, SELECT
    ON SEQUENCES TO voyage_bot_app;

-- Migrate role
GRANT ALL ON SCHEMA voyage_bot TO voyage_bot_migrate;

ALTER DEFAULT PRIVILEGES IN SCHEMA voyage_bot
    GRANT ALL ON TABLES TO voyage_bot_migrate;

ALTER DEFAULT PRIVILEGES IN SCHEMA voyage_bot
    GRANT ALL ON SEQUENCES TO voyage_bot_migrate;

-- Readonly role
GRANT USAGE ON SCHEMA voyage_bot TO voyage_bot_read_only;

GRANT SELECT
    ON ALL TABLES IN SCHEMA voyage_bot
    TO voyage_bot_read_only;

ALTER DEFAULT PRIVILEGES IN SCHEMA voyage_bot
    GRANT SELECT
    ON TABLES TO voyage_bot_read_only;

-- Admin role
GRANT USAGE ON SCHEMA voyage_bot TO voyage_bot_admin;

GRANT SELECT, INSERT, UPDATE, DELETE
    ON ALL TABLES IN SCHEMA voyage_bot
    TO voyage_bot_admin;

ALTER DEFAULT PRIVILEGES IN SCHEMA voyage_bot
    GRANT SELECT, INSERT, UPDATE, DELETE
    ON TABLES TO voyage_bot_admin;

ALTER DEFAULT PRIVILEGES IN SCHEMA voyage_bot
    GRANT USAGE, SELECT
    ON SEQUENCES TO voyage_bot_admin;

-- ========================================
-- Search path
-- ========================================
ALTER ROLE voyage_bot_app SET search_path TO voyage_bot, public;
ALTER ROLE voyage_bot_migrate SET search_path TO voyage_bot, public;
ALTER ROLE voyage_bot_read_only SET search_path TO voyage_bot, public;
ALTER ROLE voyage_bot_admin SET search_path TO voyage_bot, public;