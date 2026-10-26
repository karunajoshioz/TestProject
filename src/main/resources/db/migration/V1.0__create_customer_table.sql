-- Dedicated schema so this app can share the same Azure database (e.g. demo_dev)
-- without colliding with other workloads in "public".
CREATE SCHEMA IF NOT EXISTS customers;

CREATE TABLE customers.customers (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_customers_email UNIQUE (email)
);

CREATE INDEX idx_customers_created_at ON customers.customers (created_at);
