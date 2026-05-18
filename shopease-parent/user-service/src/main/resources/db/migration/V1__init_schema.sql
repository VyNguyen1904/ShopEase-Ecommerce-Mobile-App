CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE users (
    user_id       UUID         NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    email         VARCHAR(255) NOT NULL UNIQUE,
    password_hash TEXT         NOT NULL,
    full_name     VARCHAR(100) NOT NULL,
    phone         VARCHAR(20),
    role          VARCHAR(20)  NOT NULL,
    avatar_url    VARCHAR(512),
    created_at    TIMESTAMPTZ  NOT NULL
);

CREATE TABLE user_addresses (
    user_id         UUID         NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    address_id      UUID         NOT NULL,
    recipient_name  VARCHAR(100) NOT NULL,
    phone           VARCHAR(20)  NOT NULL,
    street          TEXT         NOT NULL,
    district        VARCHAR(100) NOT NULL,
    city            VARCHAR(100) NOT NULL,
    default_address BOOLEAN      NOT NULL
);
