package com.shopease.cart.client;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.shopease.cart.model.ProductSnapshot;
import com.shopease.common.dto.ApiResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientResponseException;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.Optional;

@Component
public class ProductCatalogClient {
    private static final ParameterizedTypeReference<ApiResponse<ProductResponse>> PRODUCT_RESPONSE =
            new ParameterizedTypeReference<>() {
            };

    private final RestClient productClient;

    public ProductCatalogClient(RestClient.Builder restClientBuilder,
                                @Value("${clients.product-service.url:http://localhost:8082}") String productServiceUrl) {
        this.productClient = restClientBuilder.baseUrl(productServiceUrl).build();
    }

    public Optional<ProductSnapshot> find(Long productId) {
        try {
            ApiResponse<ProductResponse> response = productClient.get()
                    .uri("/api/products/{id}", productId)
                    .retrieve()
                    .body(PRODUCT_RESPONSE);
            if (response == null || !response.success() || response.data() == null) {
                return Optional.empty();
            }
            ProductResponse product = response.data();
            return Optional.of(new ProductSnapshot(product.id(), product.name(), product.price(), product.thumbnailUrl()));
        } catch (RestClientResponseException ex) {
            if (ex.getStatusCode().value() == 404) {
                return Optional.empty();
            }
            throw ex;
        }
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    private record ProductResponse(Long id, String name, String description, CategoryResponse category,
                                   BigDecimal price, int stockQuantity, double averageRating, String sellerId,
                                   String thumbnailUrl, List<String> imageUrls, boolean active, Instant createdAt) {
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    private record CategoryResponse(Long id, String name, String slug, String description) {
    }
}
