# ShopEase Backend

This is the backend project described in `docs/deep_dive.md`: a Maven multi-module Spring Boot backend with separate services for the main ShopEase domains.

## Modules

| Module | Port | Responsibility |
|---|---:|---|
| `gateway-service` | 8080 | Routes `/api/**` to backend services |
| `user-service` | 8081 | Auth, JWT-like local tokens, profile, addresses |
| `product-service` | 8082 | Products, categories, seller listings |
| `inventory-service` | 8083 | Stock, reserve, release, commit |
| `cart-service` | 8084 | Cart item add/update/remove/clear |
| `order-service` | 8085 | Place, list, detail, cancel, payment status, delivery |
| `payment-service` | 8086 | Payment transactions, simulation, refunds |
| `notification-service` | 8087 | In-app notification inbox and read state |
| `review-service` | 8089 | Product reviews and helpful counts |
| `search-service` | 8090 | Product search index and suggestions |
| `discovery-service` | 8761 | Eureka server shell |
| `common-lib` | - | Shared API response and domain event records |

Each domain service is organized with the same layered shape:

```text
src/main/java/com/shopease/<service>/
  <Service>Application.java
  controller/   REST controllers only
  service/      business logic and workflow rules
  repository/   persistence boundary, currently in-memory
  model/        domain records/entities
  dto/          request/response contracts
  config/       service configuration when needed
```

The services are currently runnable without external infrastructure so the mobile app can integrate immediately. They use in-memory repositories and seeded records, with module boundaries ready for PostgreSQL, Redis, MongoDB, Elasticsearch, Kafka, and Firebase integrations.

## Build

```powershell
cd shopease-parent
mvn test
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
- Catalog/category/seller/flash-sale APIs in `product-service`
- Product create/update syncs stock to `inventory-service` and product documents to `search-service`
- Stock reserve/release/commit APIs in `inventory-service`
- Cart CRUD APIs in `cart-service`
- Order place/list/detail/cancel/payment-status/deliver APIs in `order-service`
- Order placement now validates products through `product-service`, reserves stock through `inventory-service`, creates a pending payment through `payment-service`, and creates buyer notifications through `notification-service`
- Payment create/simulate/refund APIs in `payment-service`, with successful/failed payment simulation syncing back to `order-service`
- Notification inbox/create/read APIs in `notification-service`
- Product review/helpful APIs in `review-service`, with review creation validated against delivered buyer orders in `order-service`
- Product search/suggestion/index APIs in `search-service`

Still intentionally pending for production:

- Real database adapters and migrations
- Kafka event producers/consumers for saga flow
- Redis cart persistence and token blacklist
- Elasticsearch-backed search repository
- Firebase Storage/FCM integration
