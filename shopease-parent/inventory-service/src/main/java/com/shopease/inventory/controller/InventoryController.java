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
    ApiResponse<List<InventoryResponse>> all() {
        return ApiResponse.ok(inventory.all());
    }

    @GetMapping("/{productId}")
    ApiResponse<InventoryResponse> byProduct(@PathVariable Long productId) {
        return ApiResponse.ok(inventory.byProduct(productId));
    }

    @PutMapping("/{productId}")
    ApiResponse<InventoryResponse> upsert(@PathVariable Long productId, @Valid @RequestBody StockRequest request) {
        return ApiResponse.ok(inventory.upsert(productId, request));
    }

    @PostMapping("/reserve")
    ApiResponse<InventoryResponse> reserve(@Valid @RequestBody ReservationRequest request) {
        return ApiResponse.ok(inventory.reserve(request));
    }

    @PostMapping("/release")
    ApiResponse<InventoryResponse> release(@Valid @RequestBody ReservationRequest request) {
        return ApiResponse.ok(inventory.release(request));
    }
}
