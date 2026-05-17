package com.shopease.search.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.Instant;

@Entity
@Table(name = "product_documents")
public class ProductDocument {

    @Id
    @Column(nullable = false, updatable = false)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false, length = 4000)
    private String description;

    @Column(nullable = false)
    private String categoryName;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal price;

    @Column(nullable = false)
    private int stockQuantity;

    @Column(nullable = false)
    private double averageRating;

    @Column(nullable = false)
    private String sellerId;

    @Column(nullable = false)
    private boolean active;

    @Column(nullable = false)
    private Instant updatedAt;

    protected ProductDocument() {
    }

    public ProductDocument(Long id, String name, String description, String categoryName, BigDecimal price,
                           int stockQuantity, double averageRating, String sellerId, boolean active,
                           Instant updatedAt) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.categoryName = categoryName;
        this.price = price;
        this.stockQuantity = stockQuantity;
        this.averageRating = averageRating;
        this.sellerId = sellerId;
        this.active = active;
        this.updatedAt = updatedAt;
    }

    public ProductDocument inactive() {
        return new ProductDocument(id, name, description, categoryName, price, stockQuantity, averageRating, sellerId,
                false, Instant.now());
    }

    public Long getId() { return id; }
    public String getName() { return name; }
    public String getDescription() { return description; }
    public String getCategoryName() { return categoryName; }
    public BigDecimal getPrice() { return price; }
    public int getStockQuantity() { return stockQuantity; }
    public double getAverageRating() { return averageRating; }
    public String getSellerId() { return sellerId; }
    public boolean isActive() { return active; }
    public Instant getUpdatedAt() { return updatedAt; }
}
