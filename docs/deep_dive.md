# ShopEase — Deep-Dive Implementation Guide

**Mini Shopee — E-Commerce Platform**

> Microservices Architecture · Spring Boot Backend · Database Design

| Backend | Frontend |
|---|---|
| Java 21 + Spring Boot 3.x | Flutter 3.x (Dart) |
| Spring Cloud Microservices | Provider State Management |

| Databases | Infrastructure |
|---|---|
| PostgreSQL · Redis · MongoDB | Docker · Kubernetes |
| Elasticsearch · Firebase | Kafka · API Gateway · Eureka |

*PRM393 — Mobile Application Development (Flutter) | FPT University 2024–2025*

---

## PART 1 — System Architecture Overview
### 1.2 Microservices Breakdown

| Service | Port | Responsibility | Database | Communication |
|---|---|---|---|---|
| API Gateway | 8080 | Single entry point, routing, auth filter, rate limiting | Redis (rate limit) | REST → downstream |
| User Service | 8081 | Registration, login, JWT auth, profile management | PostgreSQL (users DB) | Publishes: user.registered |
| Product Service | 8082 | Product CRUD, category, search, image upload | PostgreSQL (products DB) | Publishes: product.updated |
| Inventory Service | 8083 | Stock levels, reservation, release on cancel | PostgreSQL (inventory DB) | Listens: order.placed, order.cancelled |
| Cart Service | 8084 | Add/remove items, cart persistence, price snapshot | Redis (cart cache) | REST to Product Service |
| Order Service | 8085 | Place order, order lifecycle, order history | PostgreSQL (orders DB) | Publishes: order.placed, order.status.* |
| Payment Service | 8086 | Simulate payment, transaction records, refunds | PostgreSQL (payments DB) | Listens: order.placed; Publishes: payment.completed |
| Notification Service | 8087 | Push via FCM, email, in-app notification inbox | MongoDB (notifications) | Listens: all domain events |
| Review Service | 8089 | Product reviews, ratings, moderation | PostgreSQL (reviews DB) | Listens: order.delivered |
| Discovery Server | 8761 | Eureka service registry | In-memory | REST (heartbeat) |

---

### 1.3 Spring Cloud Components

| Spring Cloud Component | Implementation | Purpose |
|---|---|---|
| API Gateway | Spring Cloud Gateway (Reactive) | JWT validation filter, routing, rate limiting, CORS |
| Service Discovery | Netflix Eureka Server + Client | Services register, gateway/clients discover by name |
| Circuit Breaker | Resilience4j | Fallback if downstream service is slow/down |
| Distributed Tracing | Micrometer + Zipkin | Trace a request across services end-to-end |
| Message Broker | Apache Kafka | Async events between services (order.placed, etc.) |

---

### 1.4 Request Flow: Place an Order (End-to-End)

| Step | Component | Action | Protocol |
|---|---|---|---|
| 1 | Flutter App | POST /api/orders with JWT Bearer token | HTTPS REST |
| 2 | API Gateway :8080 | Validate JWT, rate-limit check, route to order-service | Spring Cloud Gateway |
| 3 | Order Service :8085 | Create order record (status=PENDING), publish order.placed event | REST + Kafka |
| 4 | Inventory Service | Listen order.placed, reserve stock, publish inventory.reserved | Kafka Consumer |
| 5 | Payment Service | Listen inventory.reserved, process payment, publish payment.completed | Kafka Consumer |
| 6 | Order Service | Listen payment.completed, update status=CONFIRMED | Kafka Consumer |
| 7 | Notification Service | Listen payment.completed, send FCM push to buyer | Kafka Consumer + FCM |
| 8 | Flutter App | Receives push notification; polls GET /api/orders/:id for status | FCM + HTTPS REST |

---

### 1.5 Inter-Service Communication Patterns

#### 1.5.1 Synchronous (REST via Feign)

Used for real-time queries where the caller needs an immediate response:

- Cart Service → Product Service: fetch current price/availability before adding to cart
- Order Service → User Service: fetch shipping address
- Review Service → Order Service: verify buyer actually purchased the product

```java
// Cart Service — Feign client calling Product Service
@FeignClient(name = "product-service", fallbackFactory = ProductFallbackFactory.class)
public interface ProductClient {
    @GetMapping("/api/products/{id}")
    ProductDto getProduct(@PathVariable Long id);
}

// Resilience4j Circuit Breaker wraps Feign calls
@CircuitBreaker(name = "product-service", fallbackMethod = "defaultProduct")
public ProductDto getProductSafe(Long id) {
    return productClient.getProduct(id);
}
```

#### 1.5.2 Asynchronous (Apache Kafka)

Used for domain events where the publisher does not wait for consumers:

| Topic | Producer | Consumers | Trigger |
|---|---|---|---|
| user.registered | User Service | Notification Service | New user signs up |
| product.updated | Product Service | Inventory Service | Product created/edited/deleted |
| cart.checkout | Cart Service | Order Service | User confirms checkout |
| order.placed | Order Service | Inventory Service, Payment Service | Order record created |
| inventory.reserved | Inventory Service | Payment Service | Stock held for order |
| inventory.failed | Inventory Service | Order Service, Notification Service | Not enough stock |
| payment.completed | Payment Service | Order Service, Notification Service | Payment processed |
| payment.failed | Payment Service | Order Service, Inventory Service | Payment declined |
| order.status.shipped | Order Service | Notification Service | Seller marks shipped |
| order.status.delivered | Order Service | Notification, Review Service | Delivery confirmed |
| order.cancelled | Order Service | Inventory Service, Payment Service | Order cancellation |

---

## PART 2 — Service-by-Service Implementation

### 2.1 API Gateway Service

> **Port:** 8080 | Spring Boot 3.x | Spring Cloud Gateway + WebFlux
> **Dependencies:** spring-cloud-starter-gateway, spring-cloud-starter-netflix-eureka-client, spring-boot-starter-data-redis-reactive (rate limiting)

**Responsibilities:**
- Single ingress point for all Flutter client requests
- JWT validation filter — rejects unauthorized requests before they reach microservices
- Rate limiting per IP (Redis Token Bucket — 100 req/min per user)
- Request routing based on path prefix to Eureka-registered service names
- CORS configuration for Flutter web/mobile
- Request/response logging for audit

#### Route Configuration

```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: user-service
          uri: lb://user-service
          predicates:
            - Path=/api/auth/**, /api/users/**
          filters:
            - name: RequestRateLimiter
              args:
                redis-rate-limiter.replenishRate: 20
                redis-rate-limiter.burstCapacity: 50

        - id: product-service
          uri: lb://product-service
          predicates:
            - Path=/api/products/**, /api/categories/**
          filters:
            - AuthenticationFilter   # custom JWT filter

        - id: order-service
          uri: lb://order-service
          predicates:
            - Path=/api/orders/**
          filters:
            - AuthenticationFilter
            - name: CircuitBreaker
              args:
                name: order-service
                fallbackUri: forward:/fallback/orders
```

#### JWT Authentication Filter

```java
@Component
public class AuthenticationFilter implements GatewayFilter {
    @Autowired private JwtUtil jwtUtil;

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String token = exchange.getRequest().getHeaders()
            .getFirst(HttpHeaders.AUTHORIZATION);
        if (token == null || !token.startsWith("Bearer "))
            return onError(exchange, HttpStatus.UNAUTHORIZED);

        String jwt = token.substring(7);
        if (!jwtUtil.validateToken(jwt))
            return onError(exchange, HttpStatus.FORBIDDEN);

        // Forward userId in header to downstream services
        ServerHttpRequest mutated = exchange.getRequest().mutate()
            .header("X-User-Id", jwtUtil.extractUserId(jwt))
            .header("X-User-Role", jwtUtil.extractRole(jwt))
            .build();
        return chain.filter(exchange.mutate().request(mutated).build());
    }
}
```

---

### 2.2 User Service

> **Port:** 8081 | Database: PostgreSQL (shopease_users) | Cache: Redis
> **Dependencies:** spring-boot-starter-security, jjwt-api, spring-data-jpa, org.postgresql:postgresql, spring-boot-starter-data-redis

#### Package Structure

| Package | Classes | Description |
|---|---|---|
| controller | AuthController, UserController | REST endpoints for auth and user profile |
| service | AuthService, UserService, JwtService | Business logic, token generation/validation |
| repository | UserRepository, RoleRepository, TokenBlacklistRepo | JPA repositories + Redis blacklist |
| entity | User, Role, Address, RefreshToken | JPA entities mapped to PostgreSQL tables |
| dto | RegisterRequest, LoginRequest, LoginResponse, UserDto | Request/response shapes |
| security | SecurityConfig, JwtAuthFilter, UserDetailsServiceImpl | Spring Security configuration |
| event | UserRegisteredEvent, KafkaProducerConfig | Kafka event publishing |
| exception | UserNotFoundException, DuplicateEmailException, etc. | Custom exceptions + GlobalExceptionHandler |

#### Key REST Endpoints

| Method | Path | Auth | Description |
|---|---|---|---|
| POST | /api/auth/register | Public | Register new user, publish user.registered event |
| POST | /api/auth/login | Public | Login, return access token (15min) + refresh token (7d) |
| POST | /api/auth/refresh | Public | Exchange refresh token for new access token |
| POST | /api/auth/logout | Bearer | Blacklist access token in Redis |
| GET | /api/users/me | Bearer | Get authenticated user profile |
| PUT | /api/users/me | Bearer | Update profile name, phone, avatar URL |
| POST | /api/users/me/addresses | Bearer | Add shipping address |
| PUT | /api/users/me/addresses/{id} | Bearer | Update/set default address |
| DELETE | /api/users/me/addresses/{id} | Bearer | Remove address |

#### JWT Token Design

| Claim | Value | Purpose |
|---|---|---|
| sub | userId (UUID) | Identifies the token owner |
| role | BUYER / SELLER / ADMIN | Drives authorization decisions |
| email | user email | Convenience — avoid DB lookup in gateway |
| iat | Issued at timestamp | Token freshness |
| exp | iat + 900 (15 minutes) | Access token short TTL for security |
| jti | UUID v4 | Used as Redis blacklist key on logout |

---

### 2.3 Product Service

> **Port:** 8082 | Primary DB: PostgreSQL (shopease_products) | Search: Elasticsearch 8.x
> **Dependencies:** spring-data-jpa, spring-data-elasticsearch, org.postgresql:postgresql, spring-kafka, spring-cloud-starter-netflix-eureka-client

#### Key REST Endpoints

| Method | Path | Auth | Description |
|---|---|---|---|
| GET | /api/products | Public | List products (pagination, sort, filter) |
| GET | /api/products/{id} | Public | Product detail with seller info |
| GET | /api/products/search | Public | Full-text search via Elasticsearch |
| POST | /api/products | SELLER | Create new product listing |
| PUT | /api/products/{id} | SELLER | Update product (own listings only) |
| DELETE | /api/products/{id} | SELLER | Soft-delete product |
| POST | /api/products/{id}/images | SELLER | Upload product images to Firebase Storage |
| GET | /api/categories | Public | List all categories |
| POST | /api/categories | ADMIN | Create category |
| GET | /api/products/seller/{id} | Public | All products by a seller |

#### Elasticsearch Integration — ProductDocument

```java
@Document(indexName = "products")
public class ProductDocument {
    @Id private String id;  // same as PostgreSQL product_id (String form)
    @Field(type = FieldType.Text, analyzer = "standard") private String name;
    @Field(type = FieldType.Text, analyzer = "standard") private String description;
    @Field(type = FieldType.Keyword)  private String categoryName;
    @Field(type = FieldType.Double)   private BigDecimal price;
    @Field(type = FieldType.Integer)  private Integer stockQuantity;
    @Field(type = FieldType.Float)    private Float averageRating;
    @Field(type = FieldType.Keyword)  private String sellerId;
    @Field(type = FieldType.Boolean)  private boolean active;
    @Field(type = FieldType.Date)     private LocalDateTime updatedAt;
}

// Search query with filters
public Page<ProductDocument> search(String keyword, String category,
        BigDecimal minPrice, BigDecimal maxPrice, Pageable pageable) {
    Criteria c = new Criteria("name").matches(keyword)
        .and("active").is(true);
    if (category != null) c = c.and("categoryName").is(category);
    if (minPrice != null) c = c.and("price").greaterThanEqual(minPrice);
    if (maxPrice != null) c = c.and("price").lessThanEqual(maxPrice);
    return elasticsearchOperations.search(new CriteriaQuery(c), ProductDocument.class);
}
```

---

### 2.4 Inventory Service

> **Port:** 8083 | Database: PostgreSQL (shopease_inventory)
> **Listens:** order.placed, order.cancelled, order.delivered
> **Publishes:** inventory.reserved, inventory.failed

#### Key Logic: Saga Pattern for Stock Reservation

```java
@KafkaListener(topics = "order.placed", groupId = "inventory-group")
public void handleOrderPlaced(OrderPlacedEvent event) {
    for (OrderItemDto item : event.getItems()) {
        int updated = inventoryRepository.reserveStock(
            item.getProductId(), item.getQuantity());
        if (updated == 0) {
            // Publish failure — triggers order cancellation
            kafkaTemplate.send("inventory.failed",
                new InventoryFailedEvent(event.getOrderId(), item.getProductId(),
                    "Insufficient stock"));
            return;
        }
    }
    kafkaTemplate.send("inventory.reserved",
        new InventoryReservedEvent(event.getOrderId()));
}

// Atomic: only decrement if enough stock
@Query("UPDATE Inventory i SET i.availableQty = i.availableQty - :qty,"
     + " i.reservedQty = i.reservedQty + :qty"
     + " WHERE i.productId = :pid AND i.availableQty >= :qty")
@Modifying int reserveStock(@Param("pid") Long pid, @Param("qty") int qty);
```

---

### 2.5 Cart Service

> **Port:** 8084 | Storage: Redis (Hash structure, TTL 7 days)
> **Calls:** Product Service (Feign) for price snapshots

#### Redis Cart Structure

```java
// Redis Key: cart:{userId}
// Redis Type: Hash  field=productId  value=CartItemJson

public CartDto addItem(String userId, Long productId, int qty) {
    String key = "cart:" + userId;
    ProductDto product = productClient.getProduct(productId);

    CartItemValue item = CartItemValue.builder()
        .productId(productId).productName(product.getName())
        .priceSnapshot(product.getPrice())  // snapshot, not live
        .imageUrl(product.getThumbnailUrl())
        .quantity(qty).addedAt(Instant.now()).build();

    redisTemplate.opsForHash().put(key, productId.toString(),
        objectMapper.writeValueAsString(item));
    redisTemplate.expire(key, Duration.ofDays(7));
    return getCart(userId);
}
```

---

### 2.6 Order Service

> **Port:** 8085 | Database: PostgreSQL (shopease_orders)
> **Orchestrates:** Inventory reservation → Payment → Confirmation

#### Order State Machine

| Status | Trigger | Next Statuses | Kafka Event Published |
|---|---|---|---|
| PENDING | Order created by buyer | CONFIRMED, CANCELLED | order.placed |
| CONFIRMED | Payment completed | PROCESSING, CANCELLED | order.confirmed |
| PROCESSING | Seller starts preparing | SHIPPED, CANCELLED | order.processing |
| SHIPPED | Seller dispatches package | DELIVERED | order.status.shipped |
| DELIVERED | Buyer/system confirms delivery | COMPLETED, RETURNED | order.status.delivered |
| COMPLETED | Return window expired (7 days) | — | order.completed |
| CANCELLED | User cancel / payment fail / OOS | — | order.cancelled |
| RETURNED | Buyer initiates return | REFUNDED | order.returned |
| REFUNDED | Payment Service processes refund | — | order.refunded |

---

### 2.7 Payment Service

> **Port:** 8086 | Database: PostgreSQL (shopease_payments)
> **Listens:** inventory.reserved | **Publishes:** payment.completed, payment.failed
> **Integrations:** VNPay callback (production), Mock gateway (dev/test)

```java
@KafkaListener(topics = "inventory.reserved", groupId = "payment-group")
public void processPayment(InventoryReservedEvent event) {
    Order order = orderClient.getOrder(event.getOrderId());
    PaymentTransaction txn = PaymentTransaction.builder()
        .orderId(order.getId()).amount(order.getTotal())
        .method(order.getPaymentMethod()).status(PaymentStatus.PENDING)
        .build();
    transactionRepository.save(txn);

    // For COD: auto-complete. For VNPay: return payment URL to client.
    if (order.getPaymentMethod() == PaymentMethod.COD) {
        txn.setStatus(PaymentStatus.SUCCESS);
        transactionRepository.save(txn);
        kafkaTemplate.send("payment.completed",
            new PaymentCompletedEvent(order.getId(), txn.getId()));
    }
}
```

---

### 2.8 Notification Service

> **Port:** 8087 | Database: MongoDB (shopease_notifications)
> **Listens:** all domain events | **Sends:** FCM push, email (SMTP)

#### Event → Notification Mapping

| Kafka Event | Title | Body | Channel |
|---|---|---|---|
| user.registered | Welcome to ShopEase! | Start shopping now — explore thousands of products. | FCM + Email |
| order.placed | Order Confirmed #{{id}} | Your order has been placed. We're preparing it. | FCM |
| payment.completed | Payment Successful | Payment received. Seller is now processing your order. | FCM + Email |
| order.status.shipped | Your order is on the way! | Tracking: {{trackingCode}}. Est. arrival {{date}}. | FCM |
| order.status.delivered | Order Delivered! | Enjoy your purchase! Leave a review to help others. | FCM |
| order.cancelled | Order Cancelled #{{id}} | Your order was cancelled. Refund initiated if applicable. | FCM + Email |
| payment.failed | Payment Failed | Could not process payment. Please try again. | FCM + Email |
| inventory.failed | Item Out of Stock | Sorry, {{productName}} is no longer available. | FCM |

---


---

## PART 3 — Database Design (Per Microservice)

Each microservice owns its database exclusively. No service queries another service's database directly (**Database-per-Service** pattern).

| Service | Database Engine | Database Name | Why This DB? |
|---|---|---|---|
| User Service | PostgreSQL | shopease_users | Structured user data, ACID transactions for auth |
| Product Service | PostgreSQL | shopease_products | Relational product/category structure |
| Inventory Service | PostgreSQL | shopease_inventory | Strong consistency required for stock management |
| Order Service | PostgreSQL | shopease_orders | Transactional order lifecycle, financial records |
| Payment Service | PostgreSQL | shopease_payments | ACID compliance critical for money transactions |
| Review Service | PostgreSQL | shopease_reviews | Structured review data, FK to orders for validation |
| Cart Service | Redis | cart:{userId} keys | Sub-ms read/write, TTL expiry, session-like data |
| Notification Service | MongoDB | shopease_notifications | Schemaless, high-write, varied notification shapes |
| Rate Limiting | Redis | ratelimit:* keys | Atomic counters, Token Bucket algorithm |
| Token Blacklist | Redis | blacklist:* keys | Fast lookup on every request, TTL = token expiry |

---

### 3.1 User Service — shopease_users

```sql
CREATE TABLE users (
    user_id      CHAR(36)     NOT NULL PRIMARY KEY,
    email        VARCHAR(255) NOT NULL UNIQUE,
    password     VARCHAR(255) NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    phone        VARCHAR(20)  UNIQUE,
    avatar_url   VARCHAR(512),
    status       VARCHAR(50) CHECK (status IN ('ACTIVE','SUSPENDED','DELETED')) NOT NULL DEFAULT 'ACTIVE',
    email_verified BOOLEAN    NOT NULL DEFAULT FALSE,
    google_id    VARCHAR(255) UNIQUE,
    created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_email (email), INDEX idx_status (status)
);

CREATE TABLE roles (
    role_id   SMALLINT NOT NULL PRIMARY KEY ,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE user_roles (
    user_id CHAR(36) NOT NULL, role_id SMALLINT NOT NULL,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(role_id)
);

CREATE TABLE addresses (
    address_id     BIGSERIAL PRIMARY KEY,
    user_id        CHAR(36)     NOT NULL,
    recipient_name VARCHAR(100) NOT NULL,
    phone          VARCHAR(20)  NOT NULL,
    street         VARCHAR(255) NOT NULL,
    ward           VARCHAR(100),
    district       VARCHAR(100) NOT NULL,
    city           VARCHAR(100) NOT NULL,
    country        VARCHAR(100) NOT NULL DEFAULT 'Vietnam',
    is_default     BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE refresh_tokens (
    token_id    BIGSERIAL PRIMARY KEY,
    user_id     CHAR(36)     NOT NULL,
    token_hash  VARCHAR(255) NOT NULL UNIQUE,
    device_info VARCHAR(255),
    expires_at  TIMESTAMP    NOT NULL,
    revoked     BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
```

---

### 3.2 Product Service — shopease_products

```sql
CREATE TABLE categories (
    category_id   SERIAL PRIMARY KEY,
    name          VARCHAR(100) NOT NULL UNIQUE,
    slug          VARCHAR(100) NOT NULL UNIQUE,
    description   TEXT, icon_url VARCHAR(512),
    parent_id     INTEGER,
    display_order SMALLINT NOT NULL DEFAULT 0,
    is_active     BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (parent_id) REFERENCES categories(category_id)
);

CREATE TABLE products (
    product_id    BIGSERIAL PRIMARY KEY,
    seller_id     CHAR(36)     NOT NULL,
    category_id   INTEGER NOT NULL,
    name          VARCHAR(255) NOT NULL,
    slug          VARCHAR(300) NOT NULL UNIQUE,
    description   TEXT,
    base_price    DECIMAL(15,2) NOT NULL,
    sale_price    DECIMAL(15,2),
    thumbnail_url VARCHAR(512),
    status        VARCHAR(50) CHECK (status IN ('DRAFT','ACTIVE','INACTIVE','BANNED')) NOT NULL DEFAULT 'DRAFT',
    is_featured   BOOLEAN      NOT NULL DEFAULT FALSE,
    avg_rating    DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    review_count  INTEGER NOT NULL DEFAULT 0,
    sold_count    INTEGER NOT NULL DEFAULT 0,
    weight_kg     DECIMAL(6,3),
    created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    INDEX idx_seller(seller_id), INDEX idx_status(status), INDEX idx_featured(is_featured)
);

CREATE TABLE product_images (
    image_id   BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    image_url  VARCHAR(512)    NOT NULL,
    sort_order SMALLINT NOT NULL DEFAULT 0,
    is_primary BOOLEAN         NOT NULL DEFAULT FALSE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

CREATE TABLE product_attributes (
    attr_id    BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    attr_name  VARCHAR(100)    NOT NULL,
    attr_value VARCHAR(255)    NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

CREATE TABLE flash_sales (
    sale_id      BIGSERIAL PRIMARY KEY,
    product_id   BIGINT NOT NULL,
    discount_pct SMALLINT NOT NULL,
    sale_price   DECIMAL(15,2)  NOT NULL,
    qty_limit    INTEGER   NOT NULL,
    qty_sold     INTEGER   NOT NULL DEFAULT 0,
    starts_at    TIMESTAMP      NOT NULL,
    ends_at      TIMESTAMP      NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
```

---

### 3.3 Inventory Service — shopease_inventory

```sql
CREATE TABLE inventory (
    inventory_id  BIGSERIAL PRIMARY KEY,
    product_id    BIGINT NOT NULL UNIQUE,
    available_qty INTEGER    NOT NULL DEFAULT 0,
    reserved_qty  INTEGER    NOT NULL DEFAULT 0,
    reorder_level INTEGER    NOT NULL DEFAULT 5,
    warehouse_loc VARCHAR(100),
    last_updated  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version       BIGINT NOT NULL DEFAULT 0
);

CREATE TABLE stock_movements (
    movement_id  BIGSERIAL PRIMARY KEY,
    product_id   BIGINT NOT NULL,
    delta        INT             NOT NULL,
    reason VARCHAR(50) CHECK (reason IN ('RESTOCK','RESERVATION','RELEASE','SALE','ADJUSTMENT')) NOT NULL,
    reference_id VARCHAR(100),
    created_at   TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

---

### 3.4 Order Service — shopease_orders

```sql
CREATE TABLE orders (
    order_id        CHAR(36)      NOT NULL PRIMARY KEY,
    buyer_id        CHAR(36)      NOT NULL,
    status          ENUM('PENDING','CONFIRMED','PROCESSING','SHIPPED',
                         'DELIVERED','COMPLETED','CANCELLED','RETURNED','REFUNDED')
                    NOT NULL DEFAULT 'PENDING',
    subtotal        DECIMAL(15,2) NOT NULL,
    shipping_fee    DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    discount_amount DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    total_amount    DECIMAL(15,2) NOT NULL,
    payment_method VARCHAR(50) CHECK (method IN ('COD','VNPAY','MOMO','BANK_TRANSFER')) NOT NULL,
    payment_status VARCHAR(50) CHECK (payment_status IN ('UNPAID','PAID','REFUNDED')) NOT NULL DEFAULT 'UNPAID',
    ship_recipient  VARCHAR(100)  NOT NULL,
    ship_phone      VARCHAR(20)   NOT NULL,
    ship_street     VARCHAR(255)  NOT NULL,
    ship_district   VARCHAR(100)  NOT NULL,
    ship_city       VARCHAR(100)  NOT NULL,
    tracking_code   VARCHAR(100),
    note            TEXT,
    cancelled_reason VARCHAR(500),
    created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
    item_id       BIGSERIAL PRIMARY KEY,
    order_id      CHAR(36)       NOT NULL,
    product_id    BIGINT NOT NULL,
    seller_id     CHAR(36)       NOT NULL,
    product_name  VARCHAR(255)   NOT NULL,
    product_image VARCHAR(512),
    unit_price    DECIMAL(15,2)  NOT NULL,
    quantity      SMALLINT NOT NULL,
    subtotal      DECIMAL(15,2)  NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
);

CREATE TABLE order_status_history (
    history_id  BIGSERIAL PRIMARY KEY,
    order_id    CHAR(36)    NOT NULL,
    from_status VARCHAR(20),
    to_status   VARCHAR(20) NOT NULL,
    changed_by  CHAR(36),
    note        VARCHAR(500),
    changed_at  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
);
```

---

### 3.5 Payment Service — shopease_payments

```sql
CREATE TABLE payment_transactions (
    txn_id           CHAR(36)      NOT NULL PRIMARY KEY,
    order_id         CHAR(36)      NOT NULL UNIQUE,
    buyer_id         CHAR(36)      NOT NULL,
    amount           DECIMAL(15,2) NOT NULL,
    currency         CHAR(3)       NOT NULL DEFAULT 'VND',
    method VARCHAR(50) CHECK (method IN ('COD','VNPAY','MOMO','BANK_TRANSFER')) NOT NULL,
    status           VARCHAR(50) CHECK (status IN ('PENDING','SUCCESS','FAILED','REFUNDED','PARTIAL_REFUNDED')) NOT NULL,
    gateway_txn_id   VARCHAR(255),
    gateway_response JSON,
    paid_at          TIMESTAMP,
    created_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE refunds (
    refund_id   CHAR(36)      NOT NULL PRIMARY KEY,
    txn_id      CHAR(36)      NOT NULL,
    amount      DECIMAL(15,2) NOT NULL,
    reason      VARCHAR(500),
    status      VARCHAR(50) CHECK (status IN ('PENDING','COMPLETED','FAILED')) NOT NULL DEFAULT 'PENDING',
    refunded_at TIMESTAMP,
    created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (txn_id) REFERENCES payment_transactions(txn_id)
);
```

---

### 3.6 Review Service — shopease_reviews

```sql
CREATE TABLE reviews (
    review_id     BIGSERIAL PRIMARY KEY,
    product_id    BIGINT NOT NULL,
    order_id      CHAR(36)        NOT NULL,
    buyer_id      CHAR(36)        NOT NULL,
    rating        SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    title         VARCHAR(200),
    body          TEXT,
    status        VARCHAR(50) CHECK (status IN ('PENDING','APPROVED','REJECTED')) NOT NULL DEFAULT 'PENDING',
    helpful_count INTEGER NOT NULL DEFAULT 0,
    created_at    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_buyer_order_product UNIQUE (buyer_id, order_id, product_id)
);

CREATE TABLE review_images (
    image_id  BIGSERIAL PRIMARY KEY,
    review_id BIGINT NOT NULL,
    image_url VARCHAR(512)    NOT NULL,
    FOREIGN KEY (review_id) REFERENCES reviews(review_id) ON DELETE CASCADE
);
```

---

### 3.7 Notification Service — MongoDB

```java
@Document(collection = "notifications")
public class Notification {
    @Id private String id;
    private String userId;
    private String title;
    private String body;
    private NotificationType type;      // ORDER_UPDATE, PROMOTION, SYSTEM
    private Map<String, String> data;   // { orderId, productId }
    private boolean read;
    private String imageUrl;
    @CreatedDate private Instant createdAt;
    private Instant readAt;
}
// Indexes: { userId, createdAt }, { userId, read }
// TTL: createdAt expireAfterSeconds 2592000 (30 days)
```

---


---

## PART 4 — Spring Boot Project Structure & Configuration

### 4.1 Mono-Repo Layout

| Directory | Service | Description |
|---|---|---|
| shopease-parent/ | Root POM | Maven parent POM with shared dependency management |
| shopease-parent/gateway/ | API Gateway | Spring Cloud Gateway service |
| shopease-parent/discovery/ | Discovery Server | Eureka Server |
| shopease-parent/user-service/ | User Service | Auth, registration, profiles |
| shopease-parent/product-service/ | Product Service | Catalog, categories, images |
| shopease-parent/inventory-service/ | Inventory | Stock management |
| shopease-parent/cart-service/ | Cart Service | Redis-backed shopping cart |
| shopease-parent/order-service/ | Order Service | Order placement and lifecycle |
| shopease-parent/payment-service/ | Payment Service | Transaction processing |
| shopease-parent/notification-service/ | Notification | FCM + email push |
| shopease-parent/review-service/ | Review Service | Product ratings and reviews |
| shopease-parent/common-lib/ | Shared Library | DTOs, exceptions, Kafka event classes |
| docker/ | Docker | docker-compose.yml, Dockerfiles |
| k8s/ | Kubernetes | Deployment manifests per service |

---

### 4.2 Parent POM (Dependency Management)

```xml
<parent>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-parent</artifactId>
  <version>3.3.0</version>
</parent>

<properties>
  <java.version>21</java.version>
  <spring-cloud.version>2023.0.2</spring-cloud.version>
</properties>

<dependencyManagement>
  <dependencies>
    <dependency>
      <groupId>org.springframework.cloud</groupId>
      <artifactId>spring-cloud-dependencies</artifactId>
      <version>${spring-cloud.version}</version>
      <type>pom</type><scope>import</scope>
    </dependency>
  </dependencies>
</dependencyManagement>

<!-- Common dependencies in ALL child modules -->
<dependencies>
  <dependency> spring-boot-starter-actuator </dependency>
  <dependency> spring-cloud-starter-netflix-eureka-client </dependency>
  <dependency> micrometer-tracing-bridge-otel </dependency>
  <dependency> lombok </dependency>
  <dependency> mapstruct </dependency>
</dependencies>
```

---

### 4.3 Common application.yml Pattern

```yaml
spring:
  application:
    name: order-service
  datasource:
    url: jdbc:postgresql://postgres:5432/shopease_orders?useSSL=false
    username: ${DB_USER:root}
    password: ${DB_PASS:secret}
    driver-class-name: org.postgresql.Driver
  jpa:
    hibernate.ddl-auto: validate       # NEVER 'create-drop' in prod
    properties.hibernate.dialect: org.hibernate.dialect.PostgreSQLDialect
    open-in-view: false
  kafka:
    bootstrap-servers: kafka:9092
    producer:
      key-serializer: org.apache.kafka.common.serialization.StringSerializer
      value-serializer: org.springframework.kafka.support.serializer.JsonSerializer
    consumer:
      group-id: order-service-group
      auto-offset-reset: earliest
      key-deserializer: org.apache.kafka.common.serialization.StringDeserializer
      value-deserializer: org.springframework.kafka.support.serializer.JsonDeserializer

server:
  port: 8085

eureka:
  client:
    service-url:
      defaultZone: http://discovery:8761/eureka/
  instance:
    prefer-ip-address: true

management:
  endpoints.web.exposure.include: health,info,metrics,prometheus
  tracing.sampling.probability: 1.0
```

---

### 4.4 Standard Service Layer Structure (Order Service Example)

| Layer | Class | Responsibility |
|---|---|---|
| Controller | OrderController.java | @RestController, maps HTTP verbs to service calls, validates input via @Valid |
| Service | OrderService.java (interface) | Defines the contract (interface) |
| Service Impl | OrderServiceImpl.java | Business logic, transaction management (@Transactional) |
| Repository | OrderRepository.java | @Repository extends JpaRepository<Order, String> |
| Entity | Order.java, OrderItem.java | @Entity with JPA annotations, no business logic |
| DTO | CreateOrderRequest.java | Validated request body (@NotNull, @Size, etc.) |
| DTO | OrderResponse.java | Response shape (no password, no internal fields) |
| Mapper | OrderMapper.java | MapStruct @Mapper — Entity <-> DTO conversion |
| Event | OrderPlacedEvent.java | Kafka message POJO (serializable to JSON) |
| Exception | OrderNotFoundException.java | Custom exception extending RuntimeException |
| Handler | GlobalExceptionHandler.java | @RestControllerAdvice — maps exceptions to HTTP 4xx/5xx |

---

### 4.5 Docker Compose (Development)

```yaml
version: '3.9'
services:
  postgres:
    image: postgres:16
    environment:
      POSTGRES_PASSWORD: secret
      POSTGRES_DB: shopease_users
    volumes: [ postgres-data:/var/lib/postgresql/data ]
    ports: ['5432:5432']

  redis:
    image: redis:7-alpine
    ports: ['6379:6379']

  mongodb:
    image: mongo:7
    ports: ['27017:27017']

  elasticsearch:
    image: elasticsearch:8.13.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
    ports: ['9200:9200']

  kafka:
    image: confluentinc/cp-kafka:7.6.0
    depends_on: [zookeeper]
    environment:
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:9092
    ports: ['9092:9092']

  zookeeper:
    image: confluentinc/cp-zookeeper:7.6.0
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181

  discovery:
    build: ./discovery
    ports: ['8761:8761']

  gateway:
    build: ./gateway
    ports: ['8080:8080']
    depends_on: [discovery, redis]

  user-service:
    build: ./user-service
    depends_on: [postgres, kafka, discovery]
    environment:
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/shopease_users

volumes:
  postgres-data:
```

---

## PART 5 — Flutter ↔ Spring Boot Integration

### 5.1 API Client Layer in Flutter

Flutter uses **Dio** as the HTTP client with an Interceptor to automatically attach the JWT access token and handle token refresh.

```dart
// Dart — ApiClient using Dio with JWT interceptor
class ApiClient {
  static const BASE_URL = 'http://10.0.2.2:8080';  // localhost for emulator
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(baseUrl: BASE_URL,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 15)));
    _dio.interceptors.add(AuthInterceptor(_dio));
  }
}

class AuthInterceptor extends Interceptor {
  @override
  Future onRequest(options, handler) async {
    final token = await SecureStorage.getAccessToken();
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    return handler.next(options);
  }

  @override
  Future onError(DioException err, handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired — try refresh
      final refreshed = await AuthService().refreshToken();
      if (refreshed) return handler.resolve(await _retry(err.requestOptions));
    }
    return handler.next(err);
  }
}
```

---

### 5.2 Flutter Repository → Spring Service Mapping

| Flutter Repository | Spring Service | Key Methods |
|---|---|---|
| AuthRepository | User Service /api/auth/** | login(), register(), refreshToken(), logout() |
| UserRepository | User Service /api/users/** | getProfile(), updateProfile(), getAddresses(), addAddress() |
| ProductRepository | Product Service /api/products/** | getProducts(filter, page), getById(), search() |
| CartRepository | Cart Service /api/cart/** | getCart(), addItem(), updateQty(), removeItem(), clearCart() |
| OrderRepository | Order Service /api/orders/** | placeOrder(), getOrders(), getOrderById(), cancelOrder() |
| PaymentRepository | Payment Service /api/payments/** | getTransaction(), simulatePayment() |
| ReviewRepository | Review Service /api/reviews/** | getByProduct(), submitReview() |

---

### 5.3 Provider State → API Call Flow

```dart
// Flutter — CartProvider calling CartRepository
class CartProvider extends ChangeNotifier {
  final CartRepository _repo;
  Cart _cart = Cart.empty();
  bool _loading = false;
  String? _error;

  Future<void> addItem(int productId, int qty) async {
    _loading = true; notifyListeners();
    try {
      _cart = await _repo.addItem(productId, qty);   // POST /api/cart/items
      _error = null;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Failed to add item';
    } finally {
      _loading = false; notifyListeners();
    }
  }
}
```

---


---

## PART 6 — Security, Testing & Deployment

### 6.1 Security Architecture

| Layer | Mechanism | Details |
|---|---|---|
| Transport | HTTPS / TLS 1.3 | All production traffic encrypted. Dev uses HTTP for simplicity. |
| Authentication | JWT (RS256) | API Gateway validates every request. No DB hit per request. |
| Authorization | Spring Security + Roles | Method-level security: @PreAuthorize("hasRole('SELLER')") |
| Password | BCrypt (strength=12) | Never store plaintext. Spring Security PasswordEncoder. |
| Token Refresh | Rotating Refresh Tokens | Each refresh issues new access + new refresh token. Old revoked. |
| Token Blacklist | Redis SET with TTL | Logout blacklists JTI. Gateway checks Redis before forwarding. |
| Rate Limiting | Redis Token Bucket | 100 req/min per authenticated user; 20 req/min for /auth/** (public) |
| CORS | Gateway-level CORS config | Allow Flutter app origin; block others in production. |
| Input Validation | Spring @Valid + Bean Validation | All request DTOs annotated with @NotNull, @Size, @Email, etc. |
| SQL Injection | JPA parameterized queries | No raw string SQL concatenation. Spring Data JPA enforces this. |
| Secrets | Environment variables | No hardcoded passwords. Docker env_file / K8s Secrets. |

---

### 6.2 Testing Strategy

#### Spring Boot Testing Layers

| Test Type | Annotation / Tool | What to Test | Example |
|---|---|---|---|
| Unit Test | @ExtendWith(MockitoExtension) | Service logic in isolation (mock repos) | OrderService.placeOrder() — verify Kafka publish called |
| Repository Test | @DataJpaTest | JPA queries against in-memory H2 | OrderRepository.findByBuyerId() returns correct results |
| Controller Test | @WebMvcTest | HTTP layer, validation, status codes | POST /api/orders with invalid body returns 400 |
| Integration Test | @SpringBootTest + @Testcontainers | Full stack with real PostgreSQL (Docker) | Register user → login → get JWT → place order |
| Kafka Test | EmbeddedKafka | Producer/Consumer event flow | Order placed event consumed by Inventory Service |
| Contract Test | Spring Cloud Contract | Feign client contracts between services | Cart→Product Feign client matches Product controller |

#### Sample Integration Test

```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
class OrderIntegrationTest {
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16");

    @Container
    static KafkaContainer kafka = new KafkaContainer(
        DockerImageName.parse("confluentinc/cp-kafka:7.6.0"));

    @Autowired private TestRestTemplate rest;

    @Test
    void placeOrder_shouldReturnPendingOrder() {
        // 1. Register + login → get JWT
        String token = loginAndGetToken();

        // 2. Place order
        CreateOrderRequest req = buildTestOrder();
        ResponseEntity<OrderResponse> res = rest.exchange(
            RequestEntity.post("/api/orders")
                .header("Authorization", "Bearer " + token)
                .body(req), OrderResponse.class);

        assertThat(res.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(res.getBody().getStatus()).isEqualTo("PENDING");
    }
}
```

---

### 6.3 Kubernetes Deployment (Production)

```yaml
# k8s/order-service/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: order-service
  namespace: shopease
spec:
  replicas: 2
  selector:
    matchLabels: { app: order-service }
  template:
    metadata:
      labels: { app: order-service }
    spec:
      containers:
        - name: order-service
          image: shopease/order-service:1.0.0
          ports: [ { containerPort: 8085 } ]
          env:
            - name: SPRING_DATASOURCE_URL
              valueFrom:
                secretKeyRef: { name: db-secret, key: order-url }
            - name: SPRING_KAFKA_BOOTSTRAP_SERVERS
              value: kafka-service:9092
          resources:
            requests: { memory: '256Mi', cpu: '250m' }
            limits:   { memory: '512Mi', cpu: '500m' }
          readinessProbe:
            httpGet: { path: /actuator/health, port: 8085 }
            initialDelaySeconds: 20
          livenessProbe:
            httpGet: { path: /actuator/health, port: 8085 }
            initialDelaySeconds: 30
```

---

### 6.4 CI/CD Pipeline

| Stage | Tool | Action |
|---|---|---|
| Code Push | GitHub | Developer pushes to feature branch, opens PR |
| Build & Test | GitHub Actions | mvn test — runs all unit + integration tests with Testcontainers |
| Code Quality | SonarQube | Checks coverage ≥ 80%, no critical vulnerabilities |
| Docker Build | GitHub Actions | docker build -t shopease/{service}:{sha} .; push to Docker Hub |
| Deploy Dev | GitHub Actions | kubectl apply -n dev — auto-deploy on merge to develop |
| Deploy Staging | Manual approval | kubectl apply -n staging — QA testing |
| Deploy Prod | Manual approval | kubectl apply -n production — rolling update, zero downtime |
| Monitoring | Prometheus + Grafana | Metrics dashboards, alerts on error rate / latency |
| Distributed Tracing | Zipkin | Trace slow requests across services |

---

## Summary: Complete Technology Stack

| Category | Technology |
|---|---|
| Backend | Java 21 + Spring Boot 3.3 + Spring Cloud 2023 |
| API Gateway | Spring Cloud Gateway (Reactive) + Redis rate limiting |
| Service Mesh | Eureka (discovery) + Resilience4j (circuit breaker) + Feign (HTTP client) |
| Events | Apache Kafka 3.x (async domain events, Saga pattern) |
| Primary DB | PostgreSQL — User, Product, Inventory, Order, Payment, Review |
| Cache | Redis 7 — Cart storage, JWT blacklist, rate limiting, sessions |
| Document DB | MongoDB 7 — Notifications |
| Search | Elasticsearch 8 — Full-text product search with filters |
| File Storage | Firebase Storage (product/profile images) |
| Push Notify | Firebase Cloud Messaging (FCM) |
| Frontend | Flutter 3.x (Dart) + Provider + Dio  |
| DevOps | Docker + Kubernetes + GitHub Actions + Zipkin + Prometheus |
