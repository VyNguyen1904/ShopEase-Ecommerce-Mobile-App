package com.shopease.payment.client;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.util.UUID;

@Component
public class OrderClient {
    private static final Logger log = LoggerFactory.getLogger(OrderClient.class);

    private final RestClient orderClient;

    public OrderClient(RestClient.Builder restClientBuilder,
                       @Value("${clients.order-service.url:http://localhost:8085}") String orderServiceUrl) {
        this.orderClient = restClientBuilder.baseUrl(orderServiceUrl).build();
    }

    public void markPaymentStatus(UUID orderId, boolean paid) {
        try {
            orderClient.post()
                    .uri("/api/orders/{id}/payment-status", orderId)
                    .body(new PaymentStatusRequest(paid))
                    .retrieve()
                    .toBodilessEntity();
        } catch (RuntimeException ex) {
            log.warn("Failed to sync payment status {} to order {}", paid ? "PAID" : "FAILED", orderId, ex);
        }
    }

    private record PaymentStatusRequest(boolean paid) {
    }
}
