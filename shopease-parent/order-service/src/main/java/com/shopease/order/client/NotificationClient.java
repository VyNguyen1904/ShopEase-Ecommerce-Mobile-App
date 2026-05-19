package com.shopease.order.client;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.util.Map;
import java.util.UUID;

@Component
public class NotificationClient {
    private static final Logger log = LoggerFactory.getLogger(NotificationClient.class);

    private final RestClient notificationClient;

    public NotificationClient(RestClient.Builder restClientBuilder,
                              @Value("${clients.notification-service.url:http://localhost:8087}") String notificationServiceUrl) {
        this.notificationClient = restClientBuilder.baseUrl(notificationServiceUrl).build();
    }

    public void sendOrderPlaced(String userId, UUID orderId, String totalAmount) {
        send(new NotificationRequest(userId, "Order placed",
                "Your order " + orderId + " was created and payment is pending.", "ORDER_PLACED",
                Map.of("orderId", orderId.toString(), "totalAmount", totalAmount), null));
    }

    public void sendOrderCancelled(String userId, UUID orderId) {
        send(new NotificationRequest(userId, "Order cancelled",
                "Your order " + orderId + " was cancelled and reserved stock was released.", "ORDER_CANCELLED",
                Map.of("orderId", orderId.toString()), null));
    }

    public void sendPaymentStatus(String userId, UUID orderId, boolean paid) {
        String title = paid ? "Payment confirmed" : "Payment failed";
        String body = paid ? "Payment for order " + orderId + " was confirmed."
                : "Payment for order " + orderId + " failed. Reserved stock was released.";
        String type = paid ? "PAYMENT_CONFIRMED" : "PAYMENT_FAILED";
        send(new NotificationRequest(userId, title, body, type, Map.of("orderId", orderId.toString()), null));
    }

    public void sendReviewRequest(String userId, UUID orderId) {
        send(new NotificationRequest(userId, "How was your order?",
                "Your order " + orderId + " was delivered. You can now review the products.", "REVIEW_REQUEST",
                Map.of("orderId", orderId.toString()), null));
    }

    private void send(NotificationRequest request) {
        try {
            notificationClient.post()
                    .uri("/api/notifications")
                    .body(request)
                    .retrieve()
                    .toBodilessEntity();
        } catch (RuntimeException ex) {
            log.warn("Notification service call failed for user {} and type {}", request.userId(), request.type(), ex);
        }
    }

    private record NotificationRequest(String userId, String title, String body, String type, Map<String, String> data,
                                       String imageUrl) {
    }
}
