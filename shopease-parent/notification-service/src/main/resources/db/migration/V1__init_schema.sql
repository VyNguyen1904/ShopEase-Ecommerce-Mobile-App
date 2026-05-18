CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE notifications (
    id         UUID          NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id    TEXT          NOT NULL,
    title      TEXT          NOT NULL,
    body       VARCHAR(2000) NOT NULL,
    type       VARCHAR(50)   NOT NULL,
    data       JSONB,
    read       BOOLEAN       NOT NULL DEFAULT FALSE,
    image_url  VARCHAR(512),
    created_at TIMESTAMPTZ   NOT NULL,
    read_at    TIMESTAMPTZ
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
