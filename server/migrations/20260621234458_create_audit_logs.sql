CREATE TABLE IF NOT EXISTS voyage_bot.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID REFERENCES voyage_bot.brands(id),
    user_id UUID REFERENCES voyage_bot.users(id),
    action TEXT NOT NULL,
    table_name TEXT NOT NULL,
    record_id UUID NOT NULL,
    old_data JSONB,
    new_data JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT audit_logs_action_non_empty
        CHECK (char_length(trim(action)) > 0),
    CONSTRAINT audit_logs_action_max_length
        CHECK (char_length(action) <= 100),
    CONSTRAINT audit_logs_action_format
        CHECK (action ~ '^[a-z_]+\.[a-z_]+$'),

    CONSTRAINT audit_logs_table_non_empty
        CHECK (char_length(trim(table_name)) > 0),

    CONSTRAINT audit_logs_user_agent_max_length
        CHECK (user_agent IS NULL OR char_length(user_agent) <= 512),

    CONSTRAINT audit_logs_created_at_not_future
        CHECK (created_at <= NOW())
);

CREATE INDEX idx_audit_logs_brand_id ON voyage_bot.audit_logs(brand_id);
CREATE INDEX idx_audit_logs_user_id ON voyage_bot.audit_logs(user_id);
CREATE INDEX idx_audit_logs_record_id ON voyage_bot.audit_logs(record_id);
CREATE INDEX idx_audit_logs_action ON voyage_bot.audit_logs(action);
CREATE INDEX idx_audit_logs_created_at ON voyage_bot.audit_logs(created_at);

ALTER TABLE voyage_bot.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE voyage_bot.audit_logs FORCE ROW LEVEL SECURITY;

CREATE POLICY audit_logs_isolation ON voyage_bot.audit_logs
    USING (
        brand_id = current_setting('app.current_brand_id', TRUE)::UUID
        OR user_id = current_setting('app.current_user_id', TRUE)::UUID
    );

REVOKE UPDATE, DELETE ON voyage_bot.audit_logs FROM voyage_bot_admin;
REVOKE UPDATE, DELETE ON voyage_bot.audit_logs FROM voyage_bot_app;