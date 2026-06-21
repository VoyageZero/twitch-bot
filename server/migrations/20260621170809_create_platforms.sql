CREATE TABLE IF NOT EXISTS voyage_bot.platforms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    minimum_age INTEGER NOT NULL,
    max_connections_per_brand INTEGER NOT NULL DEFAULT 5,
    max_connections_per_user INTEGER NOT NULL DEFAULT 1,
    max_concurrent_live INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,

    CONSTRAINT platforms_name_non_empty
        CHECK (char_length(trim(name)) > 0),

    CONSTRAINT platforms_display_name_non_empty
        CHECK (char_length(trim(display_name)) > 0),

    CONSTRAINT platforms_minimum_age_realistic
        CHECK (minimum_age BETWEEN 13 AND 21),

    CONSTRAINT platforms_max_connections_per_brand_max
        CHECK (max_connections_per_brand BETWEEN 1 AND 5),

    CONSTRAINT platforms_max_connections_per_user_max
        CHECK (max_connections_per_user BETWEEN 1 AND 5),

    CONSTRAINT platforms_max_concurrent_live_max
        CHECK (max_concurrent_live BETWEEN 1 AND 5)
);