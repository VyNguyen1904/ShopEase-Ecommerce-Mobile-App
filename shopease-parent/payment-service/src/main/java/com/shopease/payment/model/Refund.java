package com.shopease.payment.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "refunds")
public class Refund {

    @Id
    private UUID id;

    @Column(nullable = false)
    private UUID transactionId;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal amount;

    @Column(length = 1000)
    private String reason;

    @Column(nullable = false)
    private String status;

    @Column(nullable = false)
    private Instant refundedAt;

    protected Refund() {
    }

    public Refund(UUID id, UUID transactionId, BigDecimal amount, String reason, String status, Instant refundedAt) {
        this.id = id;
        this.transactionId = transactionId;
        this.amount = amount;
        this.reason = reason;
        this.status = status;
        this.refundedAt = refundedAt;
    }

    public UUID getId() { return id; }
    public UUID getTransactionId() { return transactionId; }
    public BigDecimal getAmount() { return amount; }
    public String getReason() { return reason; }
    public String getStatus() { return status; }
    public Instant getRefundedAt() { return refundedAt; }
}
