package com.shopease.inventory.service;

import com.shopease.inventory.dto.InventoryDtos.ReservationRequest;
import com.shopease.inventory.dto.InventoryDtos.StockRequest;
import com.shopease.inventory.model.InventoryItem;
import com.shopease.inventory.repository.InventoryRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.util.List;

@Service
public class InventoryService {
    private final InventoryRepository inventory;

    public InventoryService(InventoryRepository inventory) {
        this.inventory = inventory;
    }

    public List<InventoryItem> all() {
        return inventory.findAll();
    }

    public InventoryItem byProduct(Long productId) {
        return inventory.findByProductId(productId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Inventory item not found"));
    }

    public InventoryItem upsert(Long productId, StockRequest request) {
        return inventory.save(new InventoryItem(productId, request.availableQty(), request.reservedQty(), Instant.now()));
    }

    public InventoryItem reserve(ReservationRequest request) {
        InventoryItem item = byProduct(request.productId());
        if (item.availableQty() < request.quantity()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Insufficient stock");
        }
        return inventory.save(new InventoryItem(item.productId(), item.availableQty() - request.quantity(),
                item.reservedQty() + request.quantity(), Instant.now()));
    }

    public InventoryItem release(ReservationRequest request) {
        InventoryItem item = byProduct(request.productId());
        return inventory.save(new InventoryItem(item.productId(), item.availableQty() + request.quantity(),
                Math.max(0, item.reservedQty() - request.quantity()), Instant.now()));
    }
}
