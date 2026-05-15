package com.shopease.order.model;

<<<<<<< HEAD
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "orders")
public class Order {
    @Id
    private UUID id;

    @Column(nullable = false)
    private String buyerId;

    @Column(nullable = false)
    private String status;

    @Column(nullable = false)
    private String paymentStatus;

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

    public Order(UUID id, String buyerId, String status, String paymentStatus, List<OrderItem> items,
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
        this.status = "CANCELLED";
    }

    public UUID getId() {
        return id;
    }

    public String getBuyerId() {
        return buyerId;
    }

    public String getStatus() {
        return status;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public List<OrderItem> getItems() {
        return List.copyOf(items);
    }

    public BigDecimal getSubtotal() {
        return subtotal;
    }

    public BigDecimal getShippingFee() {
        return shippingFee;
    }

    public BigDecimal getDiscountAmount() {
        return discountAmount;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public String getShipRecipient() {
        return shipRecipient;
    }

    public String getShipPhone() {
        return shipPhone;
    }

    public String getShipStreet() {
        return shipStreet;
    }

    public String getShipDistrict() {
        return shipDistrict;
    }

    public String getShipCity() {
        return shipCity;
    }

    public String getNote() {
        return note;
    }

    public Instant getCreatedAt() {
        return createdAt;
=======
import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record Order(UUID id, String buyerId, String status, String paymentStatus, List<OrderItem> items,
                    BigDecimal subtotal, BigDecimal shippingFee, BigDecimal discountAmount, BigDecimal totalAmount,
                    String paymentMethod, String shipRecipient, String shipPhone, String shipStreet, String shipDistrict,
                    String shipCity, String note, Instant createdAt) {
    public Order cancelled() {
        return new Order(id, buyerId, "CANCELLED", paymentStatus, items, subtotal, shippingFee, discountAmount,
                totalAmount, paymentMethod, shipRecipient, shipPhone, shipStreet, shipDistrict, shipCity, note, createdAt);
>>>>>>> 9f2b30358e4062f0be39eb86dfe53ada7c670722
    }
}
