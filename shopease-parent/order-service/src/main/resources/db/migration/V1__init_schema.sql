CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE orders (
    id              UUID          NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    buyer_id        TEXT          NOT NULL,
    status          VARCHAR(50)   NOT NULL,
    payment_status  VARCHAR(50)   NOT NULL,
    subtotal        NUMERIC(12,2) NOT NULL,
    shipping_fee    NUMERIC(12,2) NOT NULL,
    discount_amount NUMERIC(12,2) NOT NULL,
    total_amount    NUMERIC(12,2) NOT NULL,
    payment_method  TEXT          NOT NULL,
    ship_recipient  TEXT          NOT NULL,
    ship_phone      TEXT          NOT NULL,
    ship_street     TEXT          NOT NULL,
    ship_district   TEXT          NOT NULL,
    ship_city       TEXT          NOT NULL,
    note            VARCHAR(1000),
    created_at      TIMESTAMPTZ   NOT NULL
);

CREATE TABLE order_items (
    id            BIGSERIAL     PRIMARY KEY,
    order_id      UUID          NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id    BIGINT        NOT NULL,
    product_name  TEXT          NOT NULL,
    product_image TEXT,
    unit_price    NUMERIC(12,2) NOT NULL,
    quantity      INT           NOT NULL,
    subtotal      NUMERIC(12,2) NOT NULL
);
