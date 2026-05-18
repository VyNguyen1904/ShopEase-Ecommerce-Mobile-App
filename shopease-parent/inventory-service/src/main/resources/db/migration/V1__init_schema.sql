CREATE TABLE inventory_items (
    product_id    BIGINT      NOT NULL PRIMARY KEY,
    available_qty INT         NOT NULL,
    reserved_qty  INT         NOT NULL,
    updated_at    TIMESTAMPTZ NOT NULL
);
