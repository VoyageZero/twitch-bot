CREATE TABLE IF NOT EXISTS voyage_bot.users (
    id              UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name      TEXT         NOT NULL,
    last_name       TEXT,
    username        TEXT         NOT NULL UNIQUE,
    date_of_birth   DATE         NOT NULL,
    email           TEXT         NOT NULL UNIQUE,
    email_verified  BOOLEAN      NOT NULL DEFAULT false,
    password_hash   TEXT         NOT NULL,
    mfa_secret      TEXT,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ,

    CONSTRAINT users_first_name_non_empty
        CHECK (char_length(trim(first_name)) > 0),
    CONSTRAINT users_first_name_max_length
        CHECK (char_length(first_name) <= 50),
    CONSTRAINT users_first_name_regex
        CHECK (first_name ~ '^[a-zA-Z]([a-zA-Z-]*[a-zA-Z])?$'),
    CONSTRAINT users_first_name_no_repeating_hyphen
        CHECK (first_name !~ '-{2,}'),

    CONSTRAINT users_last_name_non_empty
        CHECK (last_name IS NULL OR char_length(trim(last_name)) > 0),
    CONSTRAINT users_last_name_max_length
        CHECK (last_name IS NULL OR char_length(last_name) <= 50),
    CONSTRAINT users_last_name_regex
        CHECK (last_name IS NULL OR last_name ~ '^[a-zA-Z]([a-zA-Z-]*[a-zA-Z])?$'),
    CONSTRAINT users_last_name_no_repeating_hyphen
        CHECK (last_name IS NULL OR last_name !~ '-{2,}'),

    CONSTRAINT users_username_length
        CHECK (char_length(username) BETWEEN 4 AND 25),
    CONSTRAINT users_username_format
        CHECK (username ~ '^[a-zA-Z0-9][a-zA-Z0-9_]*$'),

    CONSTRAINT users_dob_reasonable
        CHECK (date_of_birth > '1900-01-01' AND date_of_birth <= CURRENT_DATE),
    CONSTRAINT users_dob_minimum_age
        CHECK (date_of_birth <= CURRENT_DATE - INTERVAL '13 years'),

    CONSTRAINT users_email_format
        CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT users_email_max_length
        CHECK (char_length(email) <= 254),

    CONSTRAINT users_password_hash_min_length
        CHECK (char_length(password_hash) >= 60)
);

-- Row Level Security
ALTER TABLE voyage_bot.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE voyage_bot.users FORCE ROW LEVEL SECURITY;

CREATE POLICY users_isolation ON voyage_bot.users
    USING (id = current_setting('app.current_user_id', TRUE)::UUID);