package com.shopease.gateway.filter;

import com.shopease.common.dto.ApiResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.util.Map;

@Component
public class AuthenticationFilter implements GlobalFilter, Ordered {

    private final WebClient webClient;

    public AuthenticationFilter(WebClient.Builder webClientBuilder,
                                @Value("${AUTH_SERVICE_URI:http://localhost:8088}") String authServiceUri) {
        this.webClient = webClientBuilder.baseUrl(authServiceUri).build();
    }

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String path = exchange.getRequest().getURI().getPath();
        String method = exchange.getRequest().getMethod().name();

        // Skip authentication for public endpoints
        if (isPublicEndpoint(path, method)) {
            return chain.filter(exchange);
        }

        String authHeader = exchange.getRequest().getHeaders().getFirst(HttpHeaders.AUTHORIZATION);

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }

        String token = authHeader.substring(7);

        return webClient.get()
                .uri(uriBuilder -> uriBuilder
                        .path("/api/internal/auth/validate")
                        .queryParam("token", token)
                        .build())
                .retrieve()
                .bodyToMono(ApiResponse.class)
                .flatMap(apiResponse -> {
                    if (apiResponse != null && apiResponse.success() && apiResponse.data() != null) {
                        String userId = null;
                        String role = null;
                        Integer tokenVersion = null;

                        Object data = apiResponse.data();
                        if (data instanceof Map<?, ?> map) {
                            userId = (String) map.get("userId");
                            role = (String) map.get("role");
                            Object v = map.get("tokenVersion");
                            if (v instanceof Number num) {
                                tokenVersion = num.intValue();
                            }
                        } else if (data instanceof String) {
                            userId = (String) data;
                        }

                        if (userId == null) {
                            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
                            return exchange.getResponse().setComplete();
                        }

                        if (!hasRequiredRole(path, method, role)) {
                            exchange.getResponse().setStatusCode(HttpStatus.FORBIDDEN);
                            return exchange.getResponse().setComplete();
                        }

                        var requestBuilder = exchange.getRequest().mutate()
                                .header("X-User-Id", userId)
                                .header("X-User-Role", role != null ? role : "");

                        if (tokenVersion != null) {
                            requestBuilder.header("X-User-Token-Version", tokenVersion.toString());
                        }

                        return chain.filter(exchange.mutate().request(requestBuilder.build()).build());
                    } else {
                        exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
                        return exchange.getResponse().setComplete();
                    }
                })
                .onErrorResume(e -> {
                    exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
                    return exchange.getResponse().setComplete();
                });
    }

    private boolean hasRequiredRole(String path, String method, String role) {
        if ("ADMIN".equalsIgnoreCase(role)) {
            return true;
        }

        // --- Product & Category Management ---
        boolean b = "POST".equalsIgnoreCase(method) || "PUT".equalsIgnoreCase(method) || "DELETE".equalsIgnoreCase(method);
        if (path.startsWith("/api/products")) {
            // Write operations require SELLER
            if (b) {
                return "SELLER".equalsIgnoreCase(role);
            }
        }
        if (path.startsWith("/api/categories")) {
            // Write operations are ADMIN-only (and we already checked ADMIN at the top)
            if (b) {
                return false;
            }
        }

        // --- Inventory Management ---
        if (path.startsWith("/api/inventory")) {
            // Internally triggered endpoints are open to all authenticated users
            if (path.equals("/api/inventory/reserve") || path.equals("/api/inventory/release") || path.equals("/api/inventory/commit")) {
                return true;
            }
            // General stock management requires SELLER
            return "SELLER".equalsIgnoreCase(role);
        }

        // --- Cart Management ---
        // Cart is exclusively for BUYER
        if (path.startsWith("/api/cart")) {
            return "BUYER".equalsIgnoreCase(role);
        }

        // --- Order Management ---
        if (path.startsWith("/api/orders")) {
            // Placing order requires BUYER
            if ("POST".equalsIgnoreCase(method) && path.equals("/api/orders")) {
                return "BUYER".equalsIgnoreCase(role);
            }
            // Checking review eligibility requires BUYER
            if (path.contains("/review-eligibility")) {
                return "BUYER".equalsIgnoreCase(role);
            }
            // Cancel order requires BUYER
            if (path.endsWith("/cancel")) {
                return "BUYER".equalsIgnoreCase(role);
            }
            // Seller-specific orders lookup and deliver endpoints require SELLER
            if (path.startsWith("/api/orders/seller") || path.endsWith("/deliver")) {
                return "SELLER".equalsIgnoreCase(role);
            }
            // General details (GET /api/orders/{id}) or history (GET /api/orders) can be accessed by both
            return "BUYER".equalsIgnoreCase(role) || "SELLER".equalsIgnoreCase(role);
        }

        // --- Review Management ---
        // Placing reviews requires BUYER
        if (path.startsWith("/api/reviews")) {
            if ("POST".equalsIgnoreCase(method)) {
                return "BUYER".equalsIgnoreCase(role);
            }
        }

        return true;
    }

    private boolean isPublicEndpoint(String path, String method) {
        // Auth paths that do not require access token
        if (path.startsWith("/api/auth/login") || 
            path.startsWith("/api/auth/register") || 
            path.startsWith("/api/auth/refresh")) {
            return true;
        }

        // Public GET endpoints
        if ("GET".equalsIgnoreCase(method)) {
            return path.equals("/api/products") ||
                    path.startsWith("/api/products/") ||
                    path.equals("/api/categories") ||
                    path.startsWith("/api/categories/") ||
                    path.startsWith("/api/search/") ||
                    path.startsWith("/api/reviews/products/");
        }

        return false;
    }

    @Override
    public int getOrder() {
        return -1;
    }
}
