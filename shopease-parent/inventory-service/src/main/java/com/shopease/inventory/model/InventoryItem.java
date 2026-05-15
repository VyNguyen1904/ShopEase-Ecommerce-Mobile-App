package com.shopease.inventory.model;

<<<<<<< HEAD
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.Instant;

@Entity
@Table(name = "inventory_items")
public class InventoryItem {
    @Id
    @Column(name = "product_id")
    private Long productId;

    @Column(nullable = false)
    private int availableQty;

    @Column(nullable = false)
    private int reservedQty;

    @Column(nullable = false)
    private Instant updatedAt;

    protected InventoryItem() {
    }

    public InventoryItem(Long productId, int availableQty, int reservedQty, Instant updatedAt) {
        this.productId = productId;
        this.availableQty = availableQty;
        this.reservedQty = reservedQty;
        this.updatedAt = updatedAt;
    }

    public void reserve(int quantity) {
        this.availableQty -= quantity;
        this.reservedQty += quantity;
        this.updatedAt = Instant.now();
    }

    public void release(int quantity) {
        this.availableQty += quantity;
        this.reservedQty = Math.max(0, this.reservedQty - quantity);
        this.updatedAt = Instant.now();
    }

    public Long getProductId() {
        return productId;
    }

    public int getAvailableQty() {
        return availableQty;
    }

    public int getReservedQty() {
        return reservedQty;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }
=======
import java.time.Instant;

public record InventoryItem(Long productId, int availableQty, int reservedQty, Instant updatedAt) {
>>>>>>> 9f2b30358e4062f0be39eb86dfe53ada7c670722
}
