CREATE TABLE categories (
    id          BIGSERIAL     PRIMARY KEY,
    name        TEXT          NOT NULL,
    slug        TEXT          NOT NULL UNIQUE,
    description VARCHAR(1000)
);

CREATE TABLE products (
    id              BIGSERIAL        PRIMARY KEY,
    name            TEXT             NOT NULL,
    description     VARCHAR(4000)    NOT NULL,
    category_id     BIGINT           NOT NULL REFERENCES categories(id),
    price           NUMERIC(12,2)    NOT NULL,
    stock_quantity  INT              NOT NULL,
    average_rating  DOUBLE PRECISION NOT NULL,
    seller_id       TEXT             NOT NULL,
    thumbnail_url   TEXT,
    active          BOOLEAN          NOT NULL,
    created_at      TIMESTAMPTZ      NOT NULL
);

CREATE TABLE product_images (
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    image_url  TEXT   NOT NULL
);
