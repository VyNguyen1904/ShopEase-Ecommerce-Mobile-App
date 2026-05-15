package com.shopease.inventory.controller;

import com.shopease.common.dto.ApiResponse;
import com.shopease.inventory.dto.InventoryDtos.ReservationRequest;
import com.shopease.inventory.dto.InventoryDtos.StockRequest;
import com.shopease.inventory.model.InventoryItem;
import com.shopease.inventory.service.InventoryService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/inventory")
public class InventoryController {
    private final InventoryService inventory;

    public InventoryController(InventoryService inventory) {
        this.inventory = inventory;
    }

    @GetMapping
    ApiResponse<List<InventoryItem>> all() {
        return ApiResponse.ok(inventory.all());
    }

    @GetMapping("/{productId}")
    ApiResponse<InventoryItem> byProduct(@PathVariable Long productId) {
        return ApiResponse.ok(inventory.byProduct(productId));
    }

    @PutMapping("/{productId}")
    ApiResponse<InventoryItem> upsert(@PathVariable Long productId, @Valid @RequestBody StockRequest request) {
        return ApiResponse.ok(inventory.upsert(productId, request));
    }

    @PostMapping("/reserve")
    ApiResponse<InventoryItem> reserve(@Valid @RequestBody ReservationRequest request) {
        return ApiResponse.ok(inventory.reserve(request));
    }

    @PostMapping("/release")
    ApiResponse<InventoryItem> release(@Valid @RequestBody ReservationRequest request) {
        return ApiResponse.ok(inventory.release(request));
    }
}
