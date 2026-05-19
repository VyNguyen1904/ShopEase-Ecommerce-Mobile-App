CREATE TABLE refresh_tokens
(
    id                     UUID PRIMARY KEY,
    user_id                UUID                     NOT NULL,
    token_hash             VARCHAR(64)              NOT NULL UNIQUE,
    expires_at             TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at             TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    revoked_at             TIMESTAMP WITH TIME ZONE,
    replaced_by_token_hash VARCHAR(64),

    CONSTRAINT fk_refresh_tokens_user
        FOREIGN KEY (user_id)
            REFERENCES users (user_id)
            ON DELETE CASCADE
);

CREATE INDEX idx_refresh_tokens_user_id
    ON refresh_tokens (user_id);

CREATE INDEX idx_refresh_tokens_expires_at
    ON refresh_tokens (expires_at);