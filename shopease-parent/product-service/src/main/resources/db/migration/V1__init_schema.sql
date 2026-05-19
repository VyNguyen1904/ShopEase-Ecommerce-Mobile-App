CREATE TABLE categories (
    id            BIGSERIAL PRIMARY KEY,
    name          TEXT NOT NULL,
    slug          TEXT NOT NULL UNIQUE,
    description   VARCHAR(1000),
    icon_url      TEXT,
    parent_id     BIGINT REFERENCES categories(id),
    display_order INT NOT NULL DEFAULT 0,
    active        BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE products (
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

CREATE TABLE product_images (
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    image_url  TEXT NOT NULL
);

CREATE TABLE product_attributes (
    id         BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    attr_name  TEXT NOT NULL,
    attr_value TEXT NOT NULL
);

CREATE INDEX idx_products_seller ON products(seller_id);
CREATE INDEX idx_products_status ON products(status);
CREATE INDEX idx_products_featured ON products(is_featured);
