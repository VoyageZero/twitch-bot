CREATE TABLE IF NOT EXISTS voyage_bot.brands (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    username TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,

    CONSTRAINT brands_name_non_empty
        CHECK (char_length(trim(name)) > 0),
    
    CONSTRAINT brands_name_max_length
        CHECK (char_length(name) <= 50),

    CONSTRAINT brands_username_format
        CHECK (username ~ '^[a-zA-Z0-9][a-zA-Z0-9_]*$'),

    CONSTRAINT brands_username_length
        CHECK (char_length(username) BETWEEN 4 AND 25)
);

