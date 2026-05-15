package com.shopease.cart.service;

import com.shopease.cart.dto.CartDtos.*;
import com.shopease.cart.model.CartItem;
import com.shopease.cart.model.ProductSnapshot;
import com.shopease.cart.repository.CartRepository;
import com.shopease.cart.repository.ProductSnapshotRepository;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.Map;

@Service
public class CartService {
    private final CartRepository carts;
    private final ProductSnapshotRepository products;

    public CartService(CartRepository carts, ProductSnapshotRepository products) {
        this.carts = carts;
        this.products = products;
    }

    public CartResponse get(String userId) {
        return toCart(userId);
    }

    public CartResponse add(String userId, CartItemRequest request) {
        ProductSnapshot product = products.find(request.productId());
        Map<Long, CartItem> cart = carts.cartFor(userId);
        CartItem existing = cart.get(product.productId());
        int quantity = request.quantity() + (existing == null ? 0 : existing.quantity());
        cart.put(product.productId(), new CartItem(product.productId(), product.name(), product.price(), product.imageUrl(),
                quantity, Instant.now()));
        return toCart(userId);
    }

    public CartResponse update(String userId, Long productId, CartItemRequest request) {
        ProductSnapshot product = products.find(productId);
        carts.cartFor(userId).put(productId, new CartItem(productId, product.name(), product.price(), product.imageUrl(),
                request.quantity(), Instant.now()));
        return toCart(userId);
    }

    public CartResponse remove(String userId, Long productId) {
        carts.cartFor(userId).remove(productId);
        return toCart(userId);
    }

    public CartResponse clear(String userId) {
        carts.clear(userId);
        return toCart(userId);
    }

    private CartResponse toCart(String userId) {
        List<CartItemResponse> items = carts.cartFor(userId).values().stream()
                .map(item -> new CartItemResponse(item.productId(), item.productName(), item.priceSnapshot(), item.imageUrl(),
                        item.quantity(), item.priceSnapshot().multiply(BigDecimal.valueOf(item.quantity()))))
                .toList();
        return new CartResponse(userId, items, items.stream().map(CartItemResponse::subtotal).reduce(BigDecimal.ZERO, BigDecimal::add),
                items.stream().mapToInt(CartItemResponse::quantity).sum());
    }
}
