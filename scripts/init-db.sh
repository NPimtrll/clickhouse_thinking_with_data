#!/usr/bin/env bash
# ============================================================
# Auto-init script — runs inside the ClickHouse container
# on first startup via /docker-entrypoint-initdb.d/
# ============================================================

set -e

CLI="clickhouse-client --multiquery"

echo "[init-db] Creating database and tables..."
$CLI <<'EOF'
CREATE DATABASE IF NOT EXISTS greenery;

CREATE TABLE IF NOT EXISTS greenery.addresses (
    address_id  String,
    address     String,
    zipcode     Int32,
    state       String,
    country     String
) ENGINE = MergeTree() ORDER BY address_id;

CREATE TABLE IF NOT EXISTS greenery.users (
    user_id        String,
    first_name     String,
    last_name      String,
    email          String,
    phone_number   String,
    created_at     DateTime,
    updated_at     DateTime,
    address_id     String
) ENGINE = MergeTree() ORDER BY user_id;

CREATE TABLE IF NOT EXISTS greenery.promos (
    promo_id    String,
    discount    Int32,
    status      String
) ENGINE = MergeTree() ORDER BY promo_id;

CREATE TABLE IF NOT EXISTS greenery.products (
    product_id  String,
    name        String,
    price       Float64,
    inventory   Int32
) ENGINE = MergeTree() ORDER BY product_id;

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
) ENGINE = MergeTree() ORDER BY (created_at, order_id);

CREATE TABLE IF NOT EXISTS greenery.order_items (
    order_id    String,
    product_id  String,
    quantity    Int32
) ENGINE = MergeTree() ORDER BY (order_id, product_id);

CREATE TABLE IF NOT EXISTS greenery.events (
    event_id    String,
    session_id  String,
    user_id     String,
    event_type  String,
    page_url    String,
    created_at  DateTime,
    order_id    Nullable(String),
    product_id  Nullable(String)
) ENGINE = MergeTree() ORDER BY (created_at, event_id);
EOF

echo "[init-db] Loading CSVs from /data ..."

clickhouse-client --query "
    INSERT INTO greenery.addresses
    SELECT address_id, address, toInt32(zipcode), state, country
    FROM input('address_id String, address String, zipcode String, state String, country String')
    FORMAT CSVWithNames
" < /data/addresses.csv

clickhouse-client --query "
    INSERT INTO greenery.users
    SELECT user_id, first_name, last_name, email, phone_number,
           parseDateTimeBestEffort(created_at),
           parseDateTimeBestEffort(updated_at),
           address_id
    FROM input('user_id String, first_name String, last_name String, email String,
                phone_number String, created_at String, updated_at String, address_id String')
    FORMAT CSVWithNames
" < /data/users.csv

clickhouse-client --query "
    INSERT INTO greenery.promos
    SELECT trim(promo_id), toInt32(discount), trim(status)
    FROM input('promo_id String, discount String, status String')
    FORMAT CSVWithNames
" < /data/promos.csv

clickhouse-client --query "
    INSERT INTO greenery.products SELECT * FROM input('product_id String, name String, price Float64, inventory Int32')
    FORMAT CSVWithNames
" < /data/products.csv

clickhouse-client --query "
    INSERT INTO greenery.orders
    SELECT order_id, nullIf(trim(promo_id), ''), user_id, address_id,
           parseDateTimeBestEffort(created_at),
           order_cost, shipping_cost, order_total, tracking_id, shipping_service,
           if(estimated_delivery_at = '', NULL, parseDateTimeBestEffort(estimated_delivery_at)),
           if(delivered_at = '', NULL, parseDateTimeBestEffort(delivered_at)),
           status
    FROM input('order_id String, user_id String, promo_id String, address_id String,
                created_at String, order_cost Float64, shipping_cost Float64, order_total Float64,
                tracking_id String, shipping_service String, estimated_delivery_at String,
                delivered_at String, status String')
    FORMAT CSVWithNames
" < /data/orders.csv

clickhouse-client --query "
    INSERT INTO greenery.order_items SELECT * FROM input('order_id String, product_id String, quantity Int32')
    FORMAT CSVWithNames
" < /data/order_items.csv

clickhouse-client --query "
    INSERT INTO greenery.events
    SELECT event_id, session_id, user_id, event_type, page_url,
           parseDateTimeBestEffort(created_at),
           nullIf(order_id, ''), nullIf(product_id, '')
    FROM input('event_id String, session_id String, user_id String, page_url String,
                created_at String, event_type String, order_id String, product_id String')
    FORMAT CSVWithNames
" < /data/events.csv

echo "[init-db] All done!"
