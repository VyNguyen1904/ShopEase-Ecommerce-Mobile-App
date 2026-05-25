package com.shopease.order.client;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.shopease.common.dto.ApiResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientResponseException;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

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

    public ProductResponse getProduct(Long productId) {
        try {
            ApiResponse<ProductResponse> response = productClient.get()
                    .uri("/api/products/{id}", productId)
                    .retrieve()
                    .body(PRODUCT_RESPONSE);
            if (response == null || !response.success() || response.data() == null) {
                throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Product " + productId + " not found");
            }
            return response.data();
        } catch (RestClientResponseException ex) {
            if (ex.getStatusCode().value() == 404) {
                throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Product " + productId + " not found", ex);
            }
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "Product service rejected product lookup", ex);
        } catch (ResourceAccessException ex) {
            throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE, "Product service is unavailable", ex);
        }
    }

    public BigDecimal getProductPrice(Long productId) {
        ProductResponse product = getProduct(productId);
        return product.salePrice() != null ? product.salePrice() : product.basePrice();
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record ProductResponse(Long id, String name, String slug, String description, CategoryResponse category,
                                   BigDecimal basePrice, BigDecimal salePrice, int stockQuantity, double avgRating,
                                   int reviewCount, int soldCount, BigDecimal weightKg, String sellerId,
                                   String thumbnailUrl, List<String> imageUrls, String status, boolean isFeatured,
                                   boolean active, Instant createdAt, Instant updatedAt) {
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record CategoryResponse(Long id, String name, String slug, String description) {
    }
}
