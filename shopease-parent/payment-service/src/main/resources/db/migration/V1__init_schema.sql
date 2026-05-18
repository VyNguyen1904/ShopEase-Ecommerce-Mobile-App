CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE payment_transactions (
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

CREATE TABLE refunds (
    id             UUID          NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    transaction_id UUID          NOT NULL REFERENCES payment_transactions(id),
    amount         NUMERIC(12,2) NOT NULL,
    reason         VARCHAR(1000),
    status         VARCHAR(50)   NOT NULL,
    refunded_at    TIMESTAMPTZ   NOT NULL
);
