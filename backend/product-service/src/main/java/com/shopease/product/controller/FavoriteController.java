package com.shopease.product.controller;

import com.shopease.common.dto.ApiResponse;
import com.shopease.product.dto.ProductResponse;
import com.shopease.product.service.FavoriteService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/favorites")
@RequiredArgsConstructor
public class FavoriteController {

    private final FavoriteService favoriteService;

    @GetMapping
    public ApiResponse<List<ProductResponse>> getUserFavorites(
            @RequestHeader(value = "X-User-Id", required = false) String userId) {
        if (userId == null || userId.isEmpty()) {
            throw new IllegalArgumentException("User ID is required");
        }
        return ApiResponse.ok(favoriteService.getUserFavorites(userId));
    }

    @PostMapping("/{productId}")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<Void> addFavorite(
            @RequestHeader(value = "X-User-Id", required = false) String userId,
            @PathVariable Long productId) {
        if (userId == null || userId.isEmpty()) {
            throw new IllegalArgumentException("User ID is required");
        }
        favoriteService.addFavorite(userId, productId);
        return ApiResponse.ok(null);
    }

    @DeleteMapping("/{productId}")
    public ApiResponse<Void> removeFavorite(
            @RequestHeader(value = "X-User-Id", required = false) String userId,
            @PathVariable Long productId) {
        if (userId == null || userId.isEmpty()) {
            throw new IllegalArgumentException("User ID is required");
        }
        favoriteService.removeFavorite(userId, productId);
        return ApiResponse.ok(null);
    }
}
