CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE reviews (
    id            UUID          NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    product_id    BIGINT        NOT NULL,
    order_id      UUID          NOT NULL,
    buyer_id      TEXT          NOT NULL,
    rating        INT           NOT NULL,
    title         TEXT          NOT NULL,
    body          VARCHAR(4000) NOT NULL,
    status        VARCHAR(50)   NOT NULL,
    helpful_count INT           NOT NULL DEFAULT 0,
    created_at    TIMESTAMPTZ   NOT NULL
);

CREATE TABLE review_images (
    review_id UUID NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL
);
