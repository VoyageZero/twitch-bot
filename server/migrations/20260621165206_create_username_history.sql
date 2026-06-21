CREATE TABLE IF NOT EXISTS voyage_bot.username_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES voyage_bot.users(id)
        ON DELETE CASCADE,
    old_username TEXT NOT NULL,
    new_username TEXT NOT NULL,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT username_history_old_non_empty
        CHECK (char_length(trim(old_username)) > 0),

    CONSTRAINT username_history_new_non_empty
        CHECK (char_length(trim(new_username)) > 0)
);

CREATE INDEX idx_username_history_user_id
    ON voyage_bot.username_history(user_id);

CREATE INDEX idx_username_history_old_username
    ON voyage_bot.username_history(old_username);

ALTER TABLE voyage_bot.username_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE voyage_bot.username_history FORCE ROW LEVEL SECURITY;

CREATE POLICY username_history_isolation ON voyage_bot.username_history
    USING (user_id = current_setting('app.current_user_id', TRUE)::UUID);

CREATE OR REPLACE FUNCTION voyage_bot.log_username_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.username IS DISTINCT FROM NEW.username THEN
        INSERT INTO  voyage_bot.username_history (user_id, old_username, new_username)
        VALUES (OLD.id, OLD.username, NEW.username);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER log_username_change
    AFTER UPDATE ON voyage_bot.users
    FOR EACH ROW
    EXECUTE FUNCTION voyage_bot.log_username_change();