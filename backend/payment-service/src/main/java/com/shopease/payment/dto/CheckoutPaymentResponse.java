package com.shopease.payment.dto;

import java.time.Instant;

public record CheckoutPaymentResponse(
        String transactionId,
        String orderId,
        String status,
        String message,
        Instant timestamp
) {
    public CheckoutPaymentResponse withMessage(String nextMessage) {
        return new CheckoutPaymentResponse(transactionId, orderId, status, nextMessage, timestamp);
    }

    public CheckoutPaymentResponse withStatus(String nextStatus, String nextMessage) {
        return new CheckoutPaymentResponse(transactionId, orderId, nextStatus, nextMessage, Instant.now());
    }
}
