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
                    if (apiResponse != null && apiResponse.success()) {
                        String userId = (String) apiResponse.data();
                        exchange.getRequest().mutate()
                                .header("X-User-Id", userId)
                                .build();
                        return chain.filter(exchange);
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

    private boolean isPublicEndpoint(String path, String method) {
        // Auth paths that do not require access token
        if (path.startsWith("/api/auth/login") || 
            path.startsWith("/api/auth/register") || 
            path.startsWith("/api/auth/refresh")) {
            return true;
        }

        // Public GET endpoints
        if ("GET".equalsIgnoreCase(method)) {
            if (path.equals("/api/products") || 
                path.startsWith("/api/products/") || 
                path.equals("/api/categories") || 
                path.startsWith("/api/categories/") || 
                path.startsWith("/api/search/") || 
                path.startsWith("/api/reviews/products/")) {
                return true;
            }
        }

        return false;
    }

    @Override
    public int getOrder() {
        return -1;
    }
}
