package com.shopease.product.client;

import com.shopease.product.dto.ProductDtos.ProductResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.math.BigDecimal;

@Component
public class SearchIndexClient {
    private static final Logger log = LoggerFactory.getLogger(SearchIndexClient.class);

    private final RestClient searchClient;

    public SearchIndexClient(RestClient.Builder restClientBuilder,
                             @Value("${clients.search-service.url:http://localhost:8090}") String searchServiceUrl) {
        this.searchClient = restClientBuilder.baseUrl(searchServiceUrl).build();
    }

    public void upsert(ProductResponse product) {
        try {
            searchClient.post()
                    .uri("/api/search/products")
                    .body(ProductDocumentRequest.from(product))
                    .retrieve()
                    .toBodilessEntity();
        } catch (RuntimeException ex) {
            log.warn("Failed to index product {}", product.id(), ex);
        }
    }

    public void delete(Long productId) {
        try {
            searchClient.delete()
                    .uri("/api/search/products/{id}", productId)
                    .retrieve()
                    .toBodilessEntity();
        } catch (RuntimeException ex) {
            log.warn("Failed to remove product {} from search index", productId, ex);
        }
    }

    private record ProductDocumentRequest(Long id, String name, String description, String categoryName,
                                          BigDecimal price, int stockQuantity, double averageRating,
                                          String sellerId, boolean active) {
        private static ProductDocumentRequest from(ProductResponse product) {
            return new ProductDocumentRequest(product.id(), product.name(), product.description(),
                    product.category().name(), product.price(), product.stockQuantity(), product.averageRating(),
                    product.sellerId(), product.active());
        }
    }
}
