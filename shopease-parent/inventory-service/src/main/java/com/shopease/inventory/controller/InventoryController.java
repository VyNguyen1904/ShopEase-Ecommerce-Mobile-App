package com.shopease.inventory.controller;

import lombok.RequiredArgsConstructor;

import com.shopease.common.dto.ApiResponse;
import com.shopease.inventory.dto.InventoryDtos.InventoryResponse;
import com.shopease.inventory.dto.InventoryDtos.ReservationRequest;
import com.shopease.inventory.dto.InventoryDtos.StockRequest;
import com.shopease.inventory.service.InventoryService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/inventory")
@RequiredArgsConstructor
public class InventoryController {
    private final InventoryService inventory;



    @GetMapping
    ApiResponse<List<InventoryResponse>> getAllInventoryItems() {
        return ApiResponse.ok(inventory.getAllInventoryItems());
    }

    @GetMapping("/{productId}")
    ApiResponse<InventoryResponse> getInventoryByProductId(@PathVariable Long productId) {
        return ApiResponse.ok(inventory.getInventoryByProduct(productId));
    }

    @PutMapping("/{productId}")
    ApiResponse<InventoryResponse> updateStock(@PathVariable Long productId, @Valid @RequestBody StockRequest request) {
        return ApiResponse.ok(inventory.updateStock(productId, request));
    }

    @PostMapping("/reserve")
    ApiResponse<InventoryResponse> reserveStock(@Valid @RequestBody ReservationRequest request) {
        return ApiResponse.ok(inventory.reserveStock(request));
    }

    @PostMapping("/release")
    ApiResponse<InventoryResponse> releaseStock(@Valid @RequestBody ReservationRequest request) {
        return ApiResponse.ok(inventory.releaseStock(request));
    }

    @PostMapping("/commit")
    ApiResponse<InventoryResponse> commitStock(@Valid @RequestBody ReservationRequest request) {
        return ApiResponse.ok(inventory.commitStock(request));
    }
}
