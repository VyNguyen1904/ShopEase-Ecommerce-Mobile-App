package com.shopease.payment.model;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

public record Refund(UUID id, UUID transactionId, BigDecimal amount, String reason, String status, Instant refundedAt) {
}
