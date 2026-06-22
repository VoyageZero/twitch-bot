CREATE TABLE IF NOT EXISTS voyage_bot.brands (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,

    CONSTRAINT brands_name_non_empty
        CHECK (char_length(trim(name)) > 0),
    
    CONSTRAINT brands_name_max_length
        CHECK (char_length(name) <= 50),

    CONSTRAINT brands_slug_format
        CHECK (slug ~ '^[a-z0-9]([a-z0-9-]*[a-z0-9])?$'),

    CONSTRAINT brands_slug_length
        CHECK (char_length(slug) BETWEEN 4 AND 50),

    CONSTRAINT brands_slug_no_repeating_hyphen
        CHECK (slug !~ '-{2,}')
);

ALTER TABLE voyage_bot.brands ENABLE ROW LEVEL SECURITY;
ALTER TABLE voyage_bot.brands FORCE ROW LEVEL SECURITY;

CREATE POLICY brands_isolation ON voyage_bot.brands
    USING (id = current_setting('app.current_brand_id', TRUE)::UUID);

