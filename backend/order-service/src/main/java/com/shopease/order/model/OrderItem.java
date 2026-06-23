package com.shopease.order.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;

import java.math.BigDecimal;

@Getter
@Entity
@Table(name = "order_items")
public class OrderItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long productId;

    @Column(name = "product_name", nullable = false)
    private String productName;

    @Column(name = "product_image")
    private String productImage;

    @Column(name = "color")
    private String color;

    @Column(name = "size")
    private String size;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal unitPrice;

    @Column(nullable = false)
    private int quantity;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal subtotal;

    @Column(name = "seller_id", nullable = false)
    private String sellerId;

    @com.fasterxml.jackson.annotation.JsonIgnore
    @jakarta.persistence.ManyToOne(fetch = jakarta.persistence.FetchType.LAZY)
    @jakarta.persistence.JoinColumn(name = "order_id", nullable = false)
    private Order order;

    protected OrderItem() {
    }

    public OrderItem(Long productId, String productName, String productImage, BigDecimal unitPrice, int quantity,
                     BigDecimal subtotal, String sellerId) {
        this(productId, productName, productImage, unitPrice, quantity, subtotal, sellerId, null, null);
    }

    public OrderItem(Long productId, String productName, String productImage, BigDecimal unitPrice, int quantity,
                     BigDecimal subtotal, String sellerId, String color, String size) {
        this.productId = productId;
        this.productName = productName;
        this.productImage = productImage;
        this.unitPrice = unitPrice;
        this.quantity = quantity;
        this.subtotal = subtotal;
        this.sellerId = sellerId;
        this.color = color;
        this.size = size;
    }

    public void setOrder(Order order) {
        this.order = order;
    }

}
