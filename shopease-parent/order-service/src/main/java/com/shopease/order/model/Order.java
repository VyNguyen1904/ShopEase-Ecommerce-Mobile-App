package com.shopease.order.model;

import com.shopease.common.domain.OrderStatus;
import com.shopease.common.domain.PaymentStatus;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Getter
@Table(name = "orders")
public class Order {

    @Id
    private UUID id;

    @Column(nullable = false)
    private String buyerId;

    @Setter
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private OrderStatus status;

    @Setter
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PaymentStatus paymentStatus;

    @OneToMany(cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
    @JoinColumn(name = "order_id")
    private List<OrderItem> items = new ArrayList<>();

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal subtotal;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal shippingFee;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal discountAmount;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal totalAmount;

    @Column(nullable = false)
    private String paymentMethod;

    @Column(nullable = false)
    private String shipRecipient;

    @Column(nullable = false)
    private String shipPhone;

    @Column(nullable = false)
    private String shipStreet;

    @Column(nullable = false)
    private String shipDistrict;

    @Column(nullable = false)
    private String shipCity;

    @Column(length = 1000)
    private String note;

    @Column(nullable = false)
    private Instant createdAt;

    protected Order() {
    }

    public Order(UUID id, String buyerId, OrderStatus status, PaymentStatus paymentStatus, List<OrderItem> items,
                 BigDecimal subtotal, BigDecimal shippingFee, BigDecimal discountAmount, BigDecimal totalAmount,
                 String paymentMethod, String shipRecipient, String shipPhone, String shipStreet,
                 String shipDistrict, String shipCity, String note, Instant createdAt) {
        this.id = id;
        this.buyerId = buyerId;
        this.status = status;
        this.paymentStatus = paymentStatus;
        this.items = new ArrayList<>(items);
        this.subtotal = subtotal;
        this.shippingFee = shippingFee;
        this.discountAmount = discountAmount;
        this.totalAmount = totalAmount;
        this.paymentMethod = paymentMethod;
        this.shipRecipient = shipRecipient;
        this.shipPhone = shipPhone;
        this.shipStreet = shipStreet;
        this.shipDistrict = shipDistrict;
        this.shipCity = shipCity;
        this.note = note;
        this.createdAt = createdAt;
    }

    public void cancel() {
        this.status = OrderStatus.CANCELLED;
    }

    public void markPaymentPaid() {
        this.paymentStatus = PaymentStatus.PAID;
    }

    public void markPaymentFailed() {
        this.paymentStatus = PaymentStatus.FAILED;
    }

    public void markDelivered() {
        this.status = OrderStatus.DELIVERED;
    }

    public boolean hasReleasableInventory() {
        return OrderStatus.PENDING.equals(status) || OrderStatus.CONFIRMED.equals(status);
    }

    public boolean hasFulfillableInventory() {
        return OrderStatus.PENDING.equals(status) || OrderStatus.CONFIRMED.equals(status);
    }
}
