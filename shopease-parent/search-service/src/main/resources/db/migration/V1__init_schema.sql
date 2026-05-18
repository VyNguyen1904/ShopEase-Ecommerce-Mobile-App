CREATE TABLE product_documents (
    id             BIGINT           NOT NULL PRIMARY KEY,
    name           TEXT             NOT NULL,
    description    VARCHAR(4000)    NOT NULL,
    category_name  TEXT             NOT NULL,
    price          NUMERIC(12,2)    NOT NULL,
    stock_quantity INT              NOT NULL,
    average_rating DOUBLE PRECISION NOT NULL,
    seller_id      TEXT             NOT NULL,
    active         BOOLEAN          NOT NULL,
    updated_at     TIMESTAMPTZ      NOT NULL
);

CREATE INDEX idx_product_documents_active ON product_documents(active);
CREATE INDEX idx_product_documents_category ON product_documents(category_name);
