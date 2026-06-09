-- ========================================
-- set_updated_at trigger function
-- ========================================

-- Automatically called by Postgres every time a row is updated in any table
-- that has the trigger attached.
CREATE OR REPLACE FUNCTION voyage_bot.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;