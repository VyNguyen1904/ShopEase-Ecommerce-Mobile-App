package com.shopease.product.client;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

@Component
public class InventorySyncClient {
    private static final Logger log = LoggerFactory.getLogger(InventorySyncClient.class);

    private final RestClient inventoryClient;

    public InventorySyncClient(RestClient.Builder restClientBuilder,
                               @Value("${clients.inventory-service.url:http://localhost:8083}") String inventoryServiceUrl) {
        this.inventoryClient = restClientBuilder.baseUrl(inventoryServiceUrl).build();
    }

    public void updateStock(Long productId, int availableQty) {
        try {
            inventoryClient.put()
                    .uri("/api/inventory/{productId}", productId)
                    .body(new StockRequest(Math.max(0, availableQty), 0))
                    .retrieve()
                    .toBodilessEntity();
        } catch (RuntimeException ex) {
            log.warn("Failed to sync inventory for product {}", productId, ex);
        }
    }

    private record StockRequest(int availableQty, int reservedQty) {
    }
}
