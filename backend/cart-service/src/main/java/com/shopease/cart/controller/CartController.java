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

    @PutMapping("/items/{itemId}")
    ApiResponse<CartResponse> updateItemQuantity(@RequestHeader(value = "X-User-Id", defaultValue = "demo-buyer") String userId,
                                                 @PathVariable String itemId, @Valid @RequestBody CartItemRequest request) {
        return ApiResponse.ok(carts.updateItemQuantity(userId, itemId, request));
    }

    @PutMapping("/items/update")
    ApiResponse<CartResponse> updateItemQuantityParam(@RequestHeader(value = "X-User-Id", defaultValue = "demo-buyer") String userId,
                                                 @RequestParam String itemId, @Valid @RequestBody CartItemRequest request) {
        return ApiResponse.ok(carts.updateItemQuantity(userId, itemId, request));
    }

    @DeleteMapping("/items/{itemId}")
    ApiResponse<CartResponse> removeItemFromCart(@RequestHeader(value = "X-User-Id", defaultValue = "demo-buyer") String userId,
                                                 @PathVariable String itemId) {
        return ApiResponse.ok(carts.removeItemFromCart(userId, itemId));
    }

    @DeleteMapping("/items/remove")
    ApiResponse<CartResponse> removeItemFromCartParam(@RequestHeader(value = "X-User-Id", defaultValue = "demo-buyer") String userId,
                                                 @RequestParam String itemId) {
        return ApiResponse.ok(carts.removeItemFromCart(userId, itemId));
    }

    @DeleteMapping
    ApiResponse<CartResponse> clearCart(@RequestHeader(value = "X-User-Id", defaultValue = "demo-buyer") String userId) {
        return ApiResponse.ok(carts.clearCart(userId));
    }
}
