# ShopEase Backend

This is the backend project described in `docs/deep_dive.md`: a Maven multi-module Spring Boot backend with separate services for the main ShopEase domains.

## Modules

| Module | Port | Responsibility |
|---|---:|---|
| `gateway-service` | 8080 | Routes `/api/**` to backend services |
| `user-service` | 8081 | Auth, JWT-like local tokens, profile, addresses |
| `product-service` | 8082 | Products, categories, seller listings, search, suggestions |
| `inventory-service` | 8083 | Stock, reserve, release, commit |
| `cart-service` | 8084 | Cart item add/update/remove/clear |
| `order-service` | 8085 | Place, list, detail, cancel, payment status, delivery |
| `payment-service` | 8086 | Payment transactions, simulation, refunds |
| `review-service` | 8089 | Product reviews and helpful counts |
| `common-lib` | - | Shared API response and domain event records |

## Database

The PostgreSQL-backed services share one database named `shopease`. `order-service` owns the Flyway migrations for the whole project schema in `order-service/src/main/resources/db/migration`, while the other SQL services keep JPA validation enabled and Flyway disabled.

In Docker Compose, the `db-migration` job runs the `order-service` migration before the SQL services start.

Each domain service is organized with the same layered shape:

```text
src/main/java/com/shopease/<service>/
  <Service>Application.java
  controller/   REST controllers only
  service/      business logic and workflow rules
  repository/   persistence boundary
  model/        domain records/entities
  dto/          request/response contracts
  config/       service configuration when needed
```

The services are currently runnable without external infrastructure so the mobile app can integrate immediately. They use seeded records and are integrated with PostgreSQL and Redis.

## Build

```powershell
cd shopease-parent
mvn package -DskipTests
```

## Run A Service

```powershell
mvn -pl user-service -am spring-boot:run
mvn -pl product-service -am spring-boot:run
mvn -pl gateway-service -am spring-boot:run
```

## Demo Accounts

All demo passwords are `password123`.

- `buyer@shopease.local`
- `seller@shopease.local`
- `admin@shopease.local`

## Flutter Base URL

Use the gateway when running multiple services:

```text
http://10.0.2.2:8080
```

For single-service testing, call the service port directly, for example `http://localhost:8082/api/products`.

## Current Implementation Scope

Implemented now:

- Auth/profile/address APIs in `user-service`
- Catalog/category/seller/search/suggestions APIs in `product-service`
- Stock reserve/release/commit APIs in `inventory-service`
- Cart CRUD APIs in `cart-service`
- Order place/list/detail/cancel/payment-status/deliver APIs in `order-service`
- Order placement validates products through `product-service`, reserves stock through `inventory-service`, and creates a pending payment through `payment-service`
- Payment create/simulate/refund APIs in `payment-service`, with successful/failed payment simulation syncing back to `order-service`
- Product review/helpful APIs in `review-service`, with review creation validated against delivered buyer orders in `order-service`

Still intentionally pending for production:

- Kafka event producers/consumers for saga flow
- Firebase Storage/FCM integration
