package com.shopease.payment.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Getter
@Entity
@Table(name = "payment_transactions")
public class PaymentTransaction {

    @Id
    private UUID id;

    @Column(nullable = false)
    private UUID orderId;

    @Column(nullable = false)
    private String buyerId;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal amount;

    @Column(nullable = false)
    private String currency;

    @Column(nullable = false)
    private String method;

    @Column(nullable = false)
    private String status;

    private String gatewayTxnId;
    private Instant paidAt;

    @Column(nullable = false)
    private Instant createdAt;

    protected PaymentTransaction() {
    }

    public PaymentTransaction(UUID id, UUID orderId, String buyerId, BigDecimal amount, String currency,
                              String method, String status, String gatewayTxnId, Instant paidAt, Instant createdAt) {
        this.id = id;
        this.orderId = orderId;
        this.buyerId = buyerId;
        this.amount = amount;
        this.currency = currency;
        this.method = method;
        this.status = status;
        this.gatewayTxnId = gatewayTxnId;
        this.paidAt = paidAt;
        this.createdAt = createdAt;
    }

    public void markCompleted() {
        this.status = "COMPLETED";
        this.gatewayTxnId = "SIM-" + id;
        this.paidAt = Instant.now();
    }

    public void markFailed() {
        this.status = "FAILED";
        this.gatewayTxnId = "SIM-" + id;
    }

}
