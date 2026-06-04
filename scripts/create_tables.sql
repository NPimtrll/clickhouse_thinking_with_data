-- ============================================================
-- Greenery Dataset — ClickHouse DDL
-- Data types follow the ERD schema
-- ============================================================

CREATE DATABASE IF NOT EXISTS greenery;

-- ------------------------------------------------------------
-- addresses
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS greenery.addresses (
    address_id  String,
    address     String,
    zipcode     Int32,
    state       String,
    country     String
)
ENGINE = MergeTree()
ORDER BY address_id;

-- ------------------------------------------------------------
-- users
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS greenery.users (
    user_id        String,
    first_name     String,
    last_name      String,
    email          String,
    phone_number   String,
    created_at     DateTime,
    updated_at     DateTime,
    address_id     String
)
ENGINE = MergeTree()
ORDER BY user_id;

-- ------------------------------------------------------------
-- promos
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS greenery.promos (
    promo_id    String,
    discount    Int32,
    status      String
)
ENGINE = MergeTree()
ORDER BY promo_id;

-- ------------------------------------------------------------
-- products
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS greenery.products (
    product_id  String,
    name        String,
    price       Float64,
    inventory   Int32
)
ENGINE = MergeTree()
ORDER BY product_id;

-- ------------------------------------------------------------
-- orders
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS greenery.orders (
    order_id                String,
    promo_id                Nullable(String),
    user_id                 String,
    address_id              String,
    created_at              DateTime,
    order_cost              Float64,
    shipping_cost           Float64,
    order_total             Float64,
    tracking_id             String,
    shipping_service        String,
    estimated_delivery_at   Nullable(DateTime),
    delivered_at            Nullable(DateTime),
    status                  String
)
ENGINE = MergeTree()
ORDER BY (created_at, order_id);

-- ------------------------------------------------------------
-- order_items
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS greenery.order_items (
    order_id    String,
    product_id  String,
    quantity    Int32
)
ENGINE = MergeTree()
ORDER BY (order_id, product_id);

-- ------------------------------------------------------------
-- events
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS greenery.events (
    event_id    String,
    session_id  String,
    user_id     String,
    event_type  String,
    page_url    String,
    created_at  DateTime,
    order_id    Nullable(String),
    product_id  Nullable(String)
)
ENGINE = MergeTree()
ORDER BY (created_at, event_id);
