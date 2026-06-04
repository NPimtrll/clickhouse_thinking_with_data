# ClickHouse Fellowship — 1 Server + 1 Keeper

Architecture: **ch-1S_1K** — single ClickHouse server backed by a single ClickHouse Keeper node.

```
┌──────────────────────┐        ┌─────────────────────────┐
│  clickhouse-server   │──9181──│   clickhouse-keeper      │
│  :8123 (HTTP)        │        │   (Raft: single node)    │
│  :9000 (native TCP)  │        └─────────────────────────┘
└──────────────────────┘
```

## Quick Start

### 1. Start containers

```bash
docker compose up -d
```

ClickHouse จะ auto-สร้าง database + tables + โหลดข้อมูลจาก `data/` ให้เองตอน startup ครั้งแรก

### 2. ตรวจสอบว่าข้อมูลโหลดครบ

```bash
docker logs clickhouse | grep "init-db"
```

เห็น `[init-db] All done!` = พร้อมใช้งาน

---

## Connect

### clickhouse-client (CLI)

```bash
# เข้า interactive shell
docker exec -it clickhouse clickhouse-client

# รัน query เดียว
docker exec -it clickhouse clickhouse-client --query "SELECT version()"
```

คำสั่งพื้นฐานใน clickhouse-client:

```sql
SHOW DATABASES;
SHOW TABLES FROM greenery;
DESCRIBE greenery.orders;
SELECT * FROM greenery.products LIMIT 5;
```

### DBeaver

1. เปิด DBeaver → **New Database Connection**
2. พิมพ์ `clickhouse` → เลือก **ClickHouse**
3. ถ้ามีถามให้ download driver → กด **Download**
4. ใส่ค่าต่อไปนี้:

| Field    | Value       |
|----------|-------------|
| Host     | `127.0.0.1` |
| Port     | `8123`      |
| Database | `greenery`  |
| Username | `default`   |
| Password | _(ว่าง)_    |

5. กด **Test Connection** → กด **Finish**
6. รัน query: คลิกขวาที่ `greenery` → **SQL Editor** → **New SQL Script**

> ถ้ามี driver ให้เลือก ให้เลือก `com.clickhouse` (ไม่ใช่ `ru.yandex`)

### Play UI (built-in)

เปิด browser ที่ [http://localhost:8123/play](http://localhost:8123/play)

---

## Port Reference

| Port   | Protocol   | ใช้กับ                              |
|--------|------------|--------------------------------------|
| `8123` | HTTP       | DBeaver, curl, Python, Play UI       |
| `9000` | Native TCP | clickhouse-client, native drivers    |
| `9181` | Keeper     | internal (ไม่ต้องแตะ)               |

---

## Reset ข้อมูล

```bash
# ลบทุกอย่างแล้วเริ่มใหม่ (init script จะรันอีกครั้ง)
docker compose down -v
docker compose up -d
```

## Stop

```bash
# หยุด containers (ข้อมูลยังอยู่)
docker compose down
```

## Pin Versions

แก้ที่ `.env`:

```env
CHVER=24.3
CHKVER=24.3-alpine
```

---

## Configuration

| File | Purpose |
|------|---------|
| `fs/volumes/clickhouse/etc/clickhouse-server/config.d/config.xml` | Server settings (ports, Keeper connection, logging) |
| `fs/volumes/clickhouse/etc/clickhouse-server/users.d/users.xml` | Users, profiles, quotas |
| `fs/volumes/clickhouse-keeper/etc/clickhouse-keeper/keeper_config.xml` | Keeper / Raft settings |
| `scripts/init-db.sh` | Auto-run สร้าง tables + โหลดข้อมูลตอน startup |
