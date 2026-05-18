package com.shopease.cart.model;

import java.math.BigDecimal;

public class ProductSnapshot {

    private Long productId;

    private String name;

    private BigDecimal price;

    private String imageUrl;

    protected ProductSnapshot() {
    }

    public ProductSnapshot(Long productId, String name, BigDecimal price, String imageUrl) {
        this.productId = productId;
        this.name = name;
        this.price = price;
        this.imageUrl = imageUrl;
    }

    public Long getProductId() { return productId; }
    public String getName() { return name; }
    public BigDecimal getPrice() { return price; }
    public String getImageUrl() { return imageUrl; }
}
