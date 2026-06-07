CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS users (
    user_id       UUID         NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    email         VARCHAR(255) NOT NULL UNIQUE,
    password_hash TEXT         NOT NULL,
    full_name     VARCHAR(100) NOT NULL,
    phone         VARCHAR(20),
    role          VARCHAR(20)  NOT NULL,
    avatar_url    VARCHAR(512),
    created_at    TIMESTAMPTZ  NOT NULL
);

CREATE TABLE IF NOT EXISTS user_addresses (
    user_id         UUID         NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    address_id      UUID         NOT NULL,
    recipient_name  VARCHAR(100) NOT NULL,
    phone           VARCHAR(20)  NOT NULL,
    street          TEXT         NOT NULL,
    district        VARCHAR(100) NOT NULL,
    city            VARCHAR(100) NOT NULL,
    default_address BOOLEAN      NOT NULL
);

CREATE TABLE IF NOT EXISTS refresh_tokens (
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

CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_id
    ON refresh_tokens (user_id);

CREATE INDEX IF NOT EXISTS idx_refresh_tokens_expires_at
    ON refresh_tokens (expires_at);

CREATE TABLE IF NOT EXISTS categories (
    id            BIGSERIAL PRIMARY KEY,
    name          TEXT NOT NULL,
    slug          TEXT NOT NULL UNIQUE,
    description   VARCHAR(1000),
    icon_url      TEXT,
    parent_id     BIGINT REFERENCES categories(id),
    display_order INT NOT NULL DEFAULT 0,
    active        BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS products (
    id              BIGSERIAL PRIMARY KEY,
    name            TEXT NOT NULL,
    slug            TEXT NOT NULL UNIQUE,
    description     VARCHAR(4000) NOT NULL,
    category_id     BIGINT NOT NULL REFERENCES categories(id),
    base_price      NUMERIC(15,2) NOT NULL,
    sale_price      NUMERIC(15,2),
    stock_quantity  INT NOT NULL,
    avg_rating      NUMERIC(3,2) NOT NULL DEFAULT 0.00,
    review_count    INT NOT NULL DEFAULT 0,
    sold_count      INT NOT NULL DEFAULT 0,
    weight_kg       NUMERIC(6,3),
    seller_id       TEXT NOT NULL,
    thumbnail_url   TEXT,
    status          TEXT NOT NULL DEFAULT 'DRAFT',
    is_featured     BOOLEAN NOT NULL DEFAULT FALSE,
    active          BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS product_images (
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    image_url  TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS product_attributes (
    id         BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    attr_name  TEXT NOT NULL,
    attr_value TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_products_seller ON products(seller_id);
CREATE INDEX IF NOT EXISTS idx_products_status ON products(status);
CREATE INDEX IF NOT EXISTS idx_products_featured ON products(is_featured);

CREATE TABLE IF NOT EXISTS inventory_items (
    product_id    BIGINT      NOT NULL PRIMARY KEY,
    available_qty INT         NOT NULL,
    reserved_qty  INT         NOT NULL,
    updated_at    TIMESTAMPTZ NOT NULL
);

CREATE TABLE IF NOT EXISTS orders (
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

CREATE TABLE IF NOT EXISTS order_items (
    id            BIGSERIAL     PRIMARY KEY,
    order_id      UUID          NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id    BIGINT        NOT NULL,
    product_name  TEXT          NOT NULL,
    product_image TEXT,
    unit_price    NUMERIC(12,2) NOT NULL,
    quantity      INT           NOT NULL,
    subtotal      NUMERIC(12,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS payment_transactions (
    id             UUID          NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    order_id       UUID          NOT NULL,
    buyer_id       TEXT          NOT NULL,
    amount         NUMERIC(12,2) NOT NULL,
    currency       VARCHAR(10)   NOT NULL,
    method         VARCHAR(50)   NOT NULL,
    status         VARCHAR(50)   NOT NULL,
    gateway_txn_id TEXT,
    paid_at        TIMESTAMPTZ,
    created_at     TIMESTAMPTZ   NOT NULL
);

CREATE TABLE IF NOT EXISTS refunds (
    id             UUID          NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    transaction_id UUID          NOT NULL REFERENCES payment_transactions(id),
    amount         NUMERIC(12,2) NOT NULL,
    reason         VARCHAR(1000),
    status         VARCHAR(50)   NOT NULL,
    refunded_at    TIMESTAMPTZ   NOT NULL
);

CREATE TABLE IF NOT EXISTS reviews (
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

CREATE TABLE IF NOT EXISTS review_images (
    review_id UUID NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL
);
