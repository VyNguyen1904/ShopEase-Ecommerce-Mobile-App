package com.shopease.cart.service;

import lombok.RequiredArgsConstructor;

import com.shopease.cart.dto.CartDtos.*;
import com.shopease.cart.model.CartItem;
import com.shopease.cart.model.ProductSnapshot;
import com.shopease.cart.repository.CartRepository;
import com.shopease.cart.repository.ProductSnapshotRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class CartService {
    private final CartRepository carts;
    private final ProductSnapshotRepository products;

    public CartResponse get(String userId) {
        return toCart(userId);
    }

    public CartResponse add(String userId, CartItemRequest request) {
        ProductSnapshot product = products.findById(request.productId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Product " + request.productId() + " not found"));
        Map<Long, CartItem> cart = carts.find(userId);
        CartItem existing = cart.get(product.getProductId());
        int quantity = request.quantity() + (existing == null ? 0 : existing.quantity());
        carts.put(userId, new CartItem(product.getProductId(), product.getName(), product.getPrice(),
                product.getImageUrl(), quantity, Instant.now()));
        return toCart(userId);
    }

    public CartResponse update(String userId, Long productId, CartItemRequest request) {
        ProductSnapshot product = products.findById(productId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Product " + productId + " not found"));
        carts.put(userId, new CartItem(productId, product.getName(), product.getPrice(),
                product.getImageUrl(), request.quantity(), Instant.now()));
        return toCart(userId);
    }

    public CartResponse remove(String userId, Long productId) {
        carts.remove(userId, productId);
        return toCart(userId);
    }

    public CartResponse clear(String userId) {
        carts.clear(userId);
        return toCart(userId);
    }

    private CartResponse toCart(String userId) {
        List<CartItemResponse> items = carts.find(userId).values().stream()
                .map(item -> new CartItemResponse(item.productId(), item.productName(), item.priceSnapshot(), item.imageUrl(),
                        item.quantity(), item.priceSnapshot().multiply(BigDecimal.valueOf(item.quantity()))))
                .toList();
        return new CartResponse(userId, items, items.stream().map(CartItemResponse::subtotal).reduce(BigDecimal.ZERO, BigDecimal::add),
                items.stream().mapToInt(CartItemResponse::quantity).sum());
    }
}
