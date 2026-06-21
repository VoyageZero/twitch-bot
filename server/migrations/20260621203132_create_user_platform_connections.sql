CREATE TABLE IF NOT EXISTS voyage_bot.user_platform_connections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES voyage_bot.users(id)
        ON DELETE CASCADE,
    platform_id UUID NOT NULL REFERENCES voyage_bot.platforms(id),
    credentials TEXT NOT NULL,
    scopes TEXT,
    is_enabled BOOLEAN NOT NULL DEFAULT true,
    connected_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT user_platform_connections_unique_per_platform
        UNIQUE (user_id, platform_id),

    CONSTRAINT user_platform_connections_credentials_non_empty
        CHECK (char_length(trim(credentials)) > 0),

    CONSTRAINT user_platform_connections_scopes_max_length
        CHECK (scopes IS NULL OR char_length(scopes) <= 1000),

    CONSTRAINT user_platform_connections_connected_at_not_future
        CHECK (connected_at <= NOW()),

    CONSTRAINT user_platform_connections_expires_after_connected
        CHECK (expires_at IS NULL OR expires_at > connected_at)
);

CREATE INDEX idx_user_platform_connections_user_id
    ON voyage_bot.user_platform_connections(user_id);

ALTER TABLE voyage_bot.user_platform_connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE voyage_bot.user_platform_connections FORCE ROW LEVEL SECURITY;

CREATE POLICY user_platform_connections_isolation
    ON voyage_bot.user_platform_connections
    USING (user_id = current_setting('app.current_user_id', TRUE)::UUID);