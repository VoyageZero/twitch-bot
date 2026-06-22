CREATE TABLE IF NOT EXISTS voyage_bot.sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID REFERENCES voyage_bot.brands(id)
        ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES voyage_bot.users(id)
        ON DELETE CASCADE,
    token_hash TEXT NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT sessions_token_hash_format
        CHECK (token_hash ~ '^[a-f0-9]{64}$'),

    CONSTRAINT sessions_expires_at_after_created
        CHECK (expires_at > created_at),

    CONSTRAINT sessions_user_agent_max_length
        CHECK (user_agent IS NULL OR char_length(user_agent) <= 512)
);

CREATE INDEX idx_sessions_brand_id ON voyage_bot.sessions(brand_id);
CREATE INDEX idx_sessions_user_id ON voyage_bot.sessions(user_id);
CREATE INDEX idx_sessions_expires_at ON voyage_bot.sessions(expires_at);

ALTER TABLE voyage_bot.sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE voyage_bot.sessions FORCE ROW LEVEL SECURITY;

CREATE POLICY sessions_isolation ON voyage_bot.sessions
    USING (user_id = current_setting('app.current_user_id', TRUE)::UUID);