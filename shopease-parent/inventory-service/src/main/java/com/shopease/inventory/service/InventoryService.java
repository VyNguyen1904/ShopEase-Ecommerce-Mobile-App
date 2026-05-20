package com.shopease.inventory.service;

import lombok.RequiredArgsConstructor;

import com.shopease.inventory.dto.ReservationRequest;
import com.shopease.inventory.dto.InventoryResponse;
import com.shopease.inventory.dto.StockRequest;
import com.shopease.inventory.model.InventoryItem;
import com.shopease.inventory.repository.InventoryRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.util.List;

@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
public class InventoryService {
    private final InventoryRepository inventory;

    public List<InventoryResponse> getAllInventoryItems() {
        return inventory.findAll().stream().map(InventoryResponse::from).toList();
    }

    public InventoryResponse getInventoryByProduct(Long productId) {
        return InventoryResponse.from(requireInventory(productId));
    }

    @Transactional
    public InventoryResponse updateStock(Long productId, StockRequest request) {
        return InventoryResponse.from(inventory.save(new InventoryItem(productId, request.availableQty(), request.reservedQty(), Instant.now())));
    }

    @Transactional
    public InventoryResponse reserveStock(ReservationRequest request) {
        InventoryItem item = requireInventoryForUpdate(request.productId());
        if (item.getAvailableQty() < request.quantity()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Insufficient stock");
        }
        item.reserve(request.quantity());
        return InventoryResponse.from(inventory.save(item));
    }

    @Transactional
    public InventoryResponse reserve(ReservationRequest request) {
        return reserveStock(request);
    }

    @Transactional
    public InventoryResponse releaseStock(ReservationRequest request) {
        InventoryItem item = requireInventoryForUpdate(request.productId());
        item.release(request.quantity());
        return InventoryResponse.from(inventory.save(item));
    }

    @Transactional
    public InventoryResponse release(ReservationRequest request) {
        return releaseStock(request);
    }

    @Transactional
    public InventoryResponse commitStock(ReservationRequest request) {
        InventoryItem item = requireInventoryForUpdate(request.productId());
        item.commit(request.quantity());
        return InventoryResponse.from(inventory.save(item));
    }

    private InventoryItem requireInventory(Long productId) {
        return inventory.findById(productId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Inventory item not found"));
    }

    private InventoryItem requireInventoryForUpdate(Long productId) {
        return inventory.findByProductIdForUpdate(productId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Inventory item not found"));
    }
}
