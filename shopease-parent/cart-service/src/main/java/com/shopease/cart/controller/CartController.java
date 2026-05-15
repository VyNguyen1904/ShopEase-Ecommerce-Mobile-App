package com.shopease.cart.controller;

import com.shopease.cart.dto.CartDtos.CartItemRequest;
import com.shopease.cart.dto.CartDtos.CartResponse;
import com.shopease.cart.service.CartService;
import com.shopease.common.dto.ApiResponse;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/cart")
public class CartController {
    private final CartService carts;

    public CartController(CartService carts) {
        this.carts = carts;
    }

    @GetMapping
    ApiResponse<CartResponse> get(@RequestHeader(value = "X-User-Id", defaultValue = "demo-buyer") String userId) {
        return ApiResponse.ok(carts.get(userId));
    }

    @PostMapping("/items")
    ApiResponse<CartResponse> add(@RequestHeader(value = "X-User-Id", defaultValue = "demo-buyer") String userId,
                                  @Valid @RequestBody CartItemRequest request) {
        return ApiResponse.ok(carts.add(userId, request));
    }

    @PutMapping("/items/{productId}")
    ApiResponse<CartResponse> update(@RequestHeader(value = "X-User-Id", defaultValue = "demo-buyer") String userId,
                                     @PathVariable Long productId, @Valid @RequestBody CartItemRequest request) {
        return ApiResponse.ok(carts.update(userId, productId, request));
    }

    @DeleteMapping("/items/{productId}")
    ApiResponse<CartResponse> remove(@RequestHeader(value = "X-User-Id", defaultValue = "demo-buyer") String userId,
                                     @PathVariable Long productId) {
        return ApiResponse.ok(carts.remove(userId, productId));
    }

    @DeleteMapping
    ApiResponse<CartResponse> clear(@RequestHeader(value = "X-User-Id", defaultValue = "demo-buyer") String userId) {
        return ApiResponse.ok(carts.clear(userId));
    }
}
