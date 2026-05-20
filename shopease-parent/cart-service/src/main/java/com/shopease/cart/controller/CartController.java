package com.shopease.cart.controller;

import lombok.RequiredArgsConstructor;

import com.shopease.cart.dto.CartItemRequest;
import com.shopease.cart.dto.CartResponse;
import com.shopease.cart.service.CartService;
import com.shopease.common.dto.ApiResponse;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/cart")
@RequiredArgsConstructor
public class CartController {
    private final CartService carts;

    @GetMapping
    ApiResponse<CartResponse> getCart(@RequestHeader(value = "X-User-Id", defaultValue = "demo-buyer") String userId) {
        return ApiResponse.ok(carts.getCart(userId));
    }

    @PostMapping("/items")
    ApiResponse<CartResponse> addItemToCart(@RequestHeader(value = "X-User-Id", defaultValue = "demo-buyer") String userId,
                                            @Valid @RequestBody CartItemRequest request) {
        return ApiResponse.ok(carts.addItemToCart(userId, request));
    }

    @PutMapping("/items/{productId}")
    ApiResponse<CartResponse> updateItemQuantity(@RequestHeader(value = "X-User-Id", defaultValue = "demo-buyer") String userId,
                                                 @PathVariable Long productId, @Valid @RequestBody CartItemRequest request) {
        return ApiResponse.ok(carts.updateItemQuantity(userId, productId, request));
    }

    @DeleteMapping("/items/{productId}")
    ApiResponse<CartResponse> removeItemFromCart(@RequestHeader(value = "X-User-Id", defaultValue = "demo-buyer") String userId,
                                                 @PathVariable Long productId) {
        return ApiResponse.ok(carts.removeItemFromCart(userId, productId));
    }

    @DeleteMapping
    ApiResponse<CartResponse> clearCart(@RequestHeader(value = "X-User-Id", defaultValue = "demo-buyer") String userId) {
        return ApiResponse.ok(carts.clearCart(userId));
    }
}
