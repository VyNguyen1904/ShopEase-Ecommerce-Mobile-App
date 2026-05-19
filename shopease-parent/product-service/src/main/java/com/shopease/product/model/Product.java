package com.shopease.product.model;

import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

@Getter
@Entity
@Table(name = "products")
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false, length = 4000)
    private String description;

    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "category_id", nullable = false)
    private Category category;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal price;

    @Column(nullable = false)
    private int stockQuantity;

    @Column(nullable = false)
    private double averageRating;

    @Column(nullable = false)
    private String sellerId;

    private String thumbnailUrl;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "product_images", joinColumns = @JoinColumn(name = "product_id"))
    @Column(name = "image_url")
    private List<String> imageUrls = new ArrayList<>();

    @Column(nullable = false)
    private boolean active;

    @Column(nullable = false)
    private Instant createdAt;

    protected Product() {
    }

    public Product(String name, String description, Category category, BigDecimal price, int stockQuantity,
                   double averageRating, String sellerId, String thumbnailUrl, List<String> imageUrls,
                   boolean active, Instant createdAt) {
        this.name = name;
        this.description = description;
        this.category = category;
        this.price = price;
        this.stockQuantity = stockQuantity;
        this.averageRating = averageRating;
        this.sellerId = sellerId;
        this.thumbnailUrl = thumbnailUrl;
        this.imageUrls = new ArrayList<>(imageUrls);
        this.active = active;
        this.createdAt = createdAt;
    }

    public void update(String name, String description, Category category, BigDecimal price, int stockQuantity,
                       String sellerId, String thumbnailUrl, List<String> imageUrls) {
        this.name = name;
        this.description = description;
        this.category = category;
        this.price = price;
        this.stockQuantity = stockQuantity;
        this.sellerId = sellerId;
        this.thumbnailUrl = thumbnailUrl;
        this.imageUrls.clear();
        this.imageUrls.addAll(imageUrls);
    }

    public void deactivate() {
        this.active = false;
    }
}
