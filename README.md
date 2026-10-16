# Gift card API

Small Rails API for brands, products, clients, and issued cards. Ruby 3.4.4, Rails 8.1, PostgreSQL.

## Setup

Start Postgres. The compose file matches the database defaults (`postgres` / `password` on port 5432).

```sh
docker compose up -d
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails server
```

The server listens on port 3000. If that port is already taken:

```sh
PORT=3001 bin/rails server
```

`config/master.key` is not in git. If Rails refuses to boot, put that key in `config/master.key`, or set `RAILS_MASTER_KEY`.

Seed creates one admin: `admin@example.com` / `password123`. Override with `ADMIN_EMAIL` and `ADMIN_PASSWORD` if you want different values.

Tests:

```sh
bundle exec rspec
```

## Calling the API

Login returns a token. Send it on later requests as `Authorization: Bearer <token>`. The token lasts one hour. Admin routes reject a client token, and client routes reject an admin token.

```sh
curl -s -X POST http://localhost:3000/api/v1/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@example.com","password":"password123"}'
```

`price_value` is an integer. `50000` means 500.00.

Card JSON never includes `pin` or `idempotency_key`.

## APIs

### Login

- `POST /api/v1/login` with `email` and `password`.

### Admin

- `POST /api/v1/admin/clients` with `email`, `password`, `payout_rate`.
- `GET /api/v1/admin/clients/:client_id/client_accessible_products`
- `PUT /api/v1/admin/clients/:client_id/client_accessible_products` with `product_ids`. This replaces the current list.
- `GET /api/v1/admin/brands`
- `GET /api/v1/admin/brands/:id`
- `POST /api/v1/admin/brands` with `name`.
- `PATCH /api/v1/admin/brands/:id`
- `PATCH /api/v1/admin/brands/:id/state` with `state` (`active` or `inactive`).
- `GET /api/v1/admin/brands/:brand_id/products`
- `POST /api/v1/admin/brands/:brand_id/products` with `name` and `price_value`.
- `PATCH /api/v1/admin/products/:id`
- `PATCH /api/v1/admin/products/:id/state`
- `DELETE /api/v1/admin/products/:id`
- `GET /api/v1/admin/audit_logs`

Audit log filters: `user_id`, `log_action`, `record_type`, `from`, `to`, `page`, `per_page` (default 25, max 100). Newest first. The response is `{ "data": [...], "meta": { "page", "per_page" } }`.

### Client

- `GET /api/v1/client/products` lists products this client can issue. Optional `brand_id` and `q` (name search).
- `POST /api/v1/client/cards` with `product_id` and `idempotency_key`. The first call is 201. The same key and product again is 200 and does not create another card.
- `GET /api/v1/client/cards`
- `GET /api/v1/client/cards/:id`
- `POST /api/v1/client/cards/:id/cancel`
