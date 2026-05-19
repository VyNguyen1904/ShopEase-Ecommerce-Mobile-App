package com.shopease.order.client;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientResponseException;
import org.springframework.web.server.ResponseStatusException;

@Component
public class InventoryClient {
    private final RestClient inventoryClient;

    public InventoryClient(RestClient.Builder restClientBuilder,
                           @Value("${clients.inventory-service.url:http://localhost:8083}") String inventoryServiceUrl) {
        this.inventoryClient = restClientBuilder.baseUrl(inventoryServiceUrl).build();
    }

    public void reserve(Long productId, int quantity) {
        postReservation("/api/inventory/reserve", productId, quantity, "reserve");
    }

    public void release(Long productId, int quantity) {
        postReservation("/api/inventory/release", productId, quantity, "release");
    }

    public void commit(Long productId, int quantity) {
        postReservation("/api/inventory/commit", productId, quantity, "commit");
    }

    private void postReservation(String path, Long productId, int quantity, String action) {
        try {
            inventoryClient.post()
                    .uri(path)
                    .body(new ReservationRequest(productId, quantity))
                    .retrieve()
                    .toBodilessEntity();
        } catch (RestClientResponseException ex) {
            int status = ex.getStatusCode().value();
            if (status == 404) {
                throw new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Inventory item for product " + productId + " not found", ex);
            }
            if (status == 409) {
                throw new ResponseStatusException(HttpStatus.CONFLICT,
                        "Insufficient stock for product " + productId, ex);
            }
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY,
                    "Inventory service failed to " + action + " product " + productId, ex);
        } catch (ResourceAccessException ex) {
            throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE, "Inventory service is unavailable", ex);
        }
    }

    private record ReservationRequest(Long productId, int quantity) {
    }
}
