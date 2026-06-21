CREATE TABLE IF NOT EXISTS voyage_bot.brand_platform_connections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES voyage_bot.brands(id)
        ON DELETE CASCADE,
    platform_id UUID NOT NULL REFERENCES voyage_bot.platforms(id),
    connected_by_user_id UUID REFERENCES voyage_bot.users(id)
        ON DELETE SET NULL,
    platform_external_account_id TEXT NOT NULL,
    is_primary BOOLEAN NOT NULL DEFAULT false,
    is_live BOOLEAN NOT NULL DEFAULT false,
    credentials TEXT NOT NULL,
    scopes TEXT[],
    is_enabled BOOLEAN NOT NULL DEFAULT true,
    connected_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT brand_platform_connections_unique_per_account
        UNIQUE (brand_id, platform_id, platform_external_account_id),
    
    CONSTRAINT brand_platform_connections_credentials_non_empty
        CHECK (char_length(trim(credentials)) > 0),

    CONSTRAINT brand_platform_connections_scopes_max_count
        CHECK (scopes IS NULL OR array_length(scopes, 1) <= 50),

    CONSTRAINT brand_platform_connections_connected_at_not_future
        CHECK (connected_at <= NOW()),

    CONSTRAINT brand_platform_connections_expires_at_after_connected
        CHECK (expires_at IS NULL OR expires_at > connected_at)
);

ALTER TABLE voyage_bot.brand_platform_connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE voyage_bot.brand_platform_connections FORCE ROW LEVEL SECURITY;

CREATE POLICY brand_platform_connections_isolation
    ON voyage_bot.brand_platform_connections
    USING (brand_id = current_setting('app.current_brand_id', TRUE)::UUID);

CREATE INDEX idx_brand_platform_connections_brand_id
    ON voyage_bot.brand_platform_connections(brand_id);

CREATE INDEX idx_brand_platform_connections_platform_id
    ON voyage_bot.brand_platform_connections(platform_id);

-- Enforces one primary account on each platform for streaming.
CREATE UNIQUE INDEX idx_one_primary_per_brand_platform
    ON voyage_bot.brand_platform_connections (brand_id, platform_id)
    WHERE is_primary = true;

-- Enforces max connections per brand per platform
CREATE OR REPLACE FUNCTION voyage_bot.enforce_brand_platform_connection_limit()
RETURNS TRIGGER AS $$
DECLARE
    connection_count INTEGER;
    max_allowed INTEGER;
BEGIN
    SELECT max_connections_per_brand INTO max_allowed
    FROM voyage_bot.platforms
    WHERE id = NEW.platform_id;

    SELECT COUNT(*) INTO connection_count
    FROM voyage_bot.brand_platform_connections
    WHERE brand_id = NEW.brand_id
        AND platform_id = NEW.platform_id
        AND is_enabled = true;

    IF connection_count >= max_allowed THEN
        RAISE EXCEPTION 'Maximum of % connections reached for this platform', max_allowed;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_brand_platform_connection_limit
    BEFORE INSERT ON voyage_bot.brand_platform_connections
    FOR EACH ROW
    EXECUTE FUNCTION voyage_bot.enforce_brand_platform_connection_limit();