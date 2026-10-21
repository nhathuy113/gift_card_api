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

Login returns a token. Later requests send `Authorization: Bearer <token>`. 
The token lasts 1 hour. Logout revokes that token. 
Client cannot access admin action and vice versa.

### Auth

| Action | API |
| --- | --- |
| Log in | `POST /api/v1/login` |
| Log out | `POST /api/v1/logout` |

### Admin

| Action | API |
| --- | --- |
| List clients | `GET /api/v1/admin/clients` |
| Show a client | `GET /api/v1/admin/clients/:id` |
| Create a client | `POST /api/v1/admin/clients` |
| Set a client active or inactive | `PATCH /api/v1/admin/clients/:id/state` |
| List products a client can access | `GET /api/v1/admin/clients/:id/client_accessible_products` |
| Set products a client can access | `PUT /api/v1/admin/clients/:id/client_accessible_products` |
| List brands | `GET /api/v1/admin/brands` |
| Create a brand | `POST /api/v1/admin/brands` |
| Show a brand | `GET /api/v1/admin/brands/:id` |
| Update a brand | `PATCH /api/v1/admin/brands/:id` |
| Set a brand active or inactive | `PATCH /api/v1/admin/brands/:id/state` |
| List products of a brand | `GET /api/v1/admin/brands/:brand_id/products` |
| Create a product | `POST /api/v1/admin/brands/:brand_id/products` |
| Show a product | `GET /api/v1/admin/products/:id` |
| Update a product | `PATCH /api/v1/admin/products/:id` |
| Delete a product | `DELETE /api/v1/admin/products/:id` |
| Set a product active or inactive | `PATCH /api/v1/admin/products/:id/state` |
| Report totals by brand | `GET /api/v1/admin/reports/brands` |
| Report totals by client | `GET /api/v1/admin/reports/clients` |
| List audit logs | `GET /api/v1/admin/audit_logs` |

### Client

| Action | API |
| --- | --- |
| List products this client can access | `GET /api/v1/client/products` |
| Report this client's spending | `GET /api/v1/client/reports` |
| Issue a card | `POST /api/v1/client/cards` |
| Cancel a card | `POST /api/v1/client/cards/cancel` |

## Examples

```sh
curl -s -X POST http://localhost:3000/api/v1/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@example.com","password":"password123"}'
```

```sh
curl -s -X POST http://localhost:3000/api/v1/client/cards/cancel \
  -H "Authorization: Bearer $CLIENT_TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"activation_number":"0000000000000001","pin":"123456"}'
```

Swagger UI: [http://localhost:3000/api-docs](http://localhost:3000/api-docs). Spec file: `swagger/v1/swagger.yaml`.
