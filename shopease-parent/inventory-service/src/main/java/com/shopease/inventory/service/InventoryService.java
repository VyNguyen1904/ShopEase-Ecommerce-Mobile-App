package com.shopease.inventory.service;

import com.shopease.inventory.dto.InventoryDtos.ReservationRequest;
import com.shopease.inventory.dto.InventoryDtos.StockRequest;
import com.shopease.inventory.model.InventoryItem;
import com.shopease.inventory.repository.InventoryRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
<<<<<<< HEAD
import org.springframework.transaction.annotation.Transactional;
=======
>>>>>>> 9f2b30358e4062f0be39eb86dfe53ada7c670722
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.util.List;

@Service
<<<<<<< HEAD
@Transactional
=======
>>>>>>> 9f2b30358e4062f0be39eb86dfe53ada7c670722
public class InventoryService {
    private final InventoryRepository inventory;

    public InventoryService(InventoryRepository inventory) {
        this.inventory = inventory;
    }

    public List<InventoryItem> all() {
        return inventory.findAll();
    }

    public InventoryItem byProduct(Long productId) {
<<<<<<< HEAD
        return inventory.findById(productId)
=======
        return inventory.findByProductId(productId)
>>>>>>> 9f2b30358e4062f0be39eb86dfe53ada7c670722
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Inventory item not found"));
    }

    public InventoryItem upsert(Long productId, StockRequest request) {
        return inventory.save(new InventoryItem(productId, request.availableQty(), request.reservedQty(), Instant.now()));
    }

    public InventoryItem reserve(ReservationRequest request) {
        InventoryItem item = byProduct(request.productId());
<<<<<<< HEAD
        if (item.getAvailableQty() < request.quantity()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Insufficient stock");
        }
        item.reserve(request.quantity());
        return inventory.save(item);
=======
        if (item.availableQty() < request.quantity()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Insufficient stock");
        }
        return inventory.save(new InventoryItem(item.productId(), item.availableQty() - request.quantity(),
                item.reservedQty() + request.quantity(), Instant.now()));
>>>>>>> 9f2b30358e4062f0be39eb86dfe53ada7c670722
    }

    public InventoryItem release(ReservationRequest request) {
        InventoryItem item = byProduct(request.productId());
<<<<<<< HEAD
        item.release(request.quantity());
        return inventory.save(item);
=======
        return inventory.save(new InventoryItem(item.productId(), item.availableQty() + request.quantity(),
                Math.max(0, item.reservedQty() - request.quantity()), Instant.now()));
>>>>>>> 9f2b30358e4062f0be39eb86dfe53ada7c670722
    }
}
