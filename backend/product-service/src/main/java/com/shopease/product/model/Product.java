package com.shopease.product.model;

import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import org.hibernate.annotations.UpdateTimestamp;

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

    @Column(nullable = false, unique = true)
    private String slug;

    @Column(nullable = false, length = 4000)
    private String description;

    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "category_id", nullable = false)
    private Category category;

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal basePrice;

    @Column(precision = 15, scale = 2)
    private BigDecimal salePrice;

    @Column(nullable = false)
    private int stockQuantity;

    @Column(nullable = false)
    private double avgRating;

    @Column(nullable = false)
    private int reviewCount;

    @Column(nullable = false)
    private int soldCount;

    @Column(precision = 6, scale = 3)
    private BigDecimal weightKg;

    @Column(nullable = false)
    private String sellerId;

    private String thumbnailUrl;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "product_images", joinColumns = @JoinColumn(name = "product_id"))
    @Column(name = "image_url")
    private List<String> imageUrls = new ArrayList<>();

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "product_colors", joinColumns = @JoinColumn(name = "product_id"))
    @Column(name = "color")
    private List<String> colors = new ArrayList<>();

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "product_sizes", joinColumns = @JoinColumn(name = "product_id"))
    @Column(name = "size")
    private List<String> sizes = new ArrayList<>();

    @Column(length = 255)
    private String material;

    @Column(length = 100)
    private String fit;

    @Column(length = 1000)
    private String careInstructions;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "product_features", joinColumns = @JoinColumn(name = "product_id"))
    @Column(name = "feature")
    private List<String> features = new ArrayList<>();

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ProductStatus status;

    @Column(nullable = false)
    private boolean isFeatured;

    @Column(nullable = false)
    private boolean active;

    @Column(nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(nullable = false)
    private Instant updatedAt;

    protected Product() {
    }

    public Product(String name, String slug, String description, Category category, BigDecimal basePrice,
                   BigDecimal salePrice, int stockQuantity, double avgRating, int reviewCount, int soldCount,
                   BigDecimal weightKg, String sellerId, String thumbnailUrl, List<String> imageUrls,
                   List<String> colors, List<String> sizes,
                   String material, String fit, String careInstructions, List<String> features,
                   ProductStatus status, boolean isFeatured, boolean active, Instant createdAt) {
        this.name = name;
        this.slug = slug;
        this.description = description;
        this.category = category;
        this.basePrice = basePrice;
        this.salePrice = salePrice;
        this.stockQuantity = stockQuantity;
        this.avgRating = avgRating;
        this.reviewCount = reviewCount;
        this.soldCount = soldCount;
        this.weightKg = weightKg;
        this.sellerId = sellerId;
        this.thumbnailUrl = thumbnailUrl;
        this.imageUrls = new ArrayList<>(imageUrls);
        this.colors = colors != null ? new ArrayList<>(colors) : new ArrayList<>();
        this.sizes = sizes != null ? new ArrayList<>(sizes) : new ArrayList<>();
        this.material = material;
        this.fit = fit;
        this.careInstructions = careInstructions;
        this.features = features != null ? new ArrayList<>(features) : new ArrayList<>();
        this.status = status;
        this.isFeatured = isFeatured;
        this.active = active;
        this.createdAt = createdAt;
        this.updatedAt = createdAt;
    }

    public void update(String name, String slug, String description, Category category, BigDecimal basePrice,
                       BigDecimal salePrice, int stockQuantity, BigDecimal weightKg, String sellerId,
                       String thumbnailUrl, List<String> imageUrls, List<String> colors, List<String> sizes,
                       String material, String fit, String careInstructions, List<String> features,
                       ProductStatus status, boolean isFeatured) {
        this.name = name;
        this.slug = slug;
        this.description = description;
        this.category = category;
        this.basePrice = basePrice;
        this.salePrice = salePrice;
        this.stockQuantity = stockQuantity;
        this.weightKg = weightKg;
        this.sellerId = sellerId;
        this.thumbnailUrl = thumbnailUrl;
        this.imageUrls.clear();
        this.imageUrls.addAll(imageUrls);
        this.colors.clear();
        if (colors != null) this.colors.addAll(colors);
        this.sizes.clear();
        if (sizes != null) this.sizes.addAll(sizes);
        this.material = material;
        this.fit = fit;
        this.careInstructions = careInstructions;
        this.features.clear();
        if (features != null) this.features.addAll(features);
        this.status = status;
        this.isFeatured = isFeatured;
    }

    public void deactivate() {
        this.active = false;
        this.status = ProductStatus.INACTIVE;
    }

    public void decreaseStockQuantity(int quantity) {
        this.stockQuantity = Math.max(0, this.stockQuantity - quantity);
    }

    public void increaseStockQuantity(int quantity) {
        this.stockQuantity += quantity;
    }

    public void increaseSoldCount(int quantity) {
        this.soldCount += quantity;
    }

    public void decreaseSoldCount(int quantity) {
        this.soldCount = Math.max(0, this.soldCount - quantity);
    }
}
