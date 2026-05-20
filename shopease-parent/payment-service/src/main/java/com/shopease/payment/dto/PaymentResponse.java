package com.shopease.payment.dto;

import com.shopease.payment.model.PaymentTransaction;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

public record PaymentResponse(
        UUID id,
        UUID orderId,
        String buyerId,
        BigDecimal amount,
        String currency,
        String method,
        String status,
        String gatewayTxnId,
        Instant paidAt,
        Instant createdAt
) {
    public static PaymentResponse from(PaymentTransaction payment) {
        return new PaymentResponse(
                payment.getId(),
                payment.getOrderId(),
                payment.getBuyerId(),
                payment.getAmount(),
                payment.getCurrency(),
                payment.getMethod(),
                payment.getStatus() != null ? payment.getStatus().name() : null,
                payment.getGatewayTxnId(),
                payment.getPaidAt(),
                payment.getCreatedAt()
        );
    }
}
