CREATE TABLE IF NOT EXISTS voyage_bot.brand_users (
    brand_id UUID NOT NULL REFERENCES voyage_bot.brands(id)
        ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES voyage_bot.users(id)
        ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES voyage_bot.roles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    PRIMARY KEY (brand_id, user_id)
);

CREATE INDEX idx_brand_users_brand_id ON voyage_bot.brand_users(brand_id);
CREATE INDEX idx_brand_users_user_id ON voyage_bot.brand_users(user_id);
CREATE INDEX idx_brand_users_role_id ON voyage_bot.brand_users(role_id);

ALTER TABLE voyage_bot.brand_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE voyage_bot.brand_users FORCE ROW LEVEL SECURITY;

CREATE POLICY brand_users_isolation ON voyage_bot.brand_users
    USING (
        user_id = current_setting('app.current_user_id', TRUE)::UUID
        OR brand_id = current_setting('app.current_brand_id', TRUE)::UUID
    );