package com.shopease.payment.model;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

public record PaymentTransaction(UUID id, UUID orderId, String buyerId, BigDecimal amount, String currency,
                                 String method, String status, String gatewayTxnId, Instant paidAt,
                                 Instant createdAt) {
    public PaymentTransaction completed() {
        return new PaymentTransaction(id, orderId, buyerId, amount, currency, method, "SUCCESS", "mock-" + id,
                Instant.now(), createdAt);
    }

    public PaymentTransaction failed() {
        return new PaymentTransaction(id, orderId, buyerId, amount, currency, method, "FAILED", null, null, createdAt);
    }
}
