# Gift card API

Rails 8.1 JSON API. Ruby 3.4.4, PostgreSQL.

## Setup

```sh
docker compose up -d
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails server
```

Postgres in compose uses `postgres` / `password` on port 5432. Seed creates `admin@example.com` / `password123`. Override with `ADMIN_EMAIL` and `ADMIN_PASSWORD`.

Swagger UI: [http://localhost:3000/api-docs](http://localhost:3000/api-docs). Spec file: `swagger/v1/swagger.yaml`.

Tests:

```sh
bundle exec rspec
```

## API

Login returns a token. Later requests send `Authorization: Bearer <token>`. The token lasts 12 hours.

```sh
curl -s -X POST http://localhost:3000/api/v1/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@example.com","password":"password123"}'
```

- `POST /api/v1/login` with `email` and `password`.
- `POST /api/v1/admin/clients` with `email`, `password`, and `payout_rate`. Admin token only.
