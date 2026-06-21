CREATE TABLE IF NOT EXISTS voyage_bot.roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    rank INTEGER NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,

    CONSTRAINT roles_name_format
        CHECK (name ~ '^[a-z][a-z_]*$'),

    CONSTRAINT roles_rank_positive
        CHECK (rank > 0),

    CONSTRAINT roles_rank_unique
        UNIQUE (rank)
);