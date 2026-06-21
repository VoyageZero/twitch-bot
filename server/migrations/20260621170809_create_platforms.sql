CREATE TABLE IF NOT EXISTS voyage_bot.platforms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    minimum_age INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,

    CONSTRAINT platforms_name_non_empty
        CHECK (char_length(trim(name)) > 0),

    CONSTRAINT platforms_minimum_age_realisitic
        CHECK (minimum_age BETWEEN 13 AND 21)
);