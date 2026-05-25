package com.shopease.payment.dto;

import com.shopease.payment.model.Refund;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

public record RefundResponse(
        UUID id,
        UUID transactionId,
        BigDecimal amount,
        String reason,
        String status,
        Instant refundedAt
) {
    public static RefundResponse from(Refund refund) {
        return new RefundResponse(
                refund.getId(),
                refund.getTransactionId(),
                refund.getAmount(),
                refund.getReason(),
                refund.getStatus(),
                refund.getRefundedAt()
        );
    }
}
