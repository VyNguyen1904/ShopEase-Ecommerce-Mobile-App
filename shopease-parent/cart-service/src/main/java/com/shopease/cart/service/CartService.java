package com.shopease.cart.service;

import lombok.RequiredArgsConstructor;

import com.shopease.cart.client.ProductCatalogClient;
import com.shopease.cart.dto.CartItemRequest;
import com.shopease.cart.dto.CartItemResponse;
import com.shopease.cart.dto.CartResponse;
import com.shopease.cart.model.CartItem;
import com.shopease.cart.repository.CartRepository;
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
    private final ProductCatalogClient products;

    public CartResponse getCart(String userId) {
        return toCart(userId);
    }

    public CartResponse addItemToCart(String userId, CartItemRequest request) {
        BigDecimal price = products.getProductPrice(request.productId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Product " + request.productId() + " not found"));
        Map<Long, CartItem> cart = carts.find(userId);
        CartItem existing = cart.get(request.productId());
        int quantity = request.quantity() + (existing == null ? 0 : existing.quantity());
        carts.put(userId, new CartItem(request.productId(), price, quantity, Instant.now()));
        return toCart(userId);
    }

    public CartResponse updateItemQuantity(String userId, Long productId, CartItemRequest request) {
        BigDecimal price = products.getProductPrice(productId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Product " + productId + " not found"));
        carts.put(userId, new CartItem(productId, price, request.quantity(), Instant.now()));
        return toCart(userId);
    }

    public CartResponse removeItemFromCart(String userId, Long productId) {
        carts.remove(userId, productId);
        return toCart(userId);
    }

    public CartResponse clearCart(String userId) {
        carts.clear(userId);
        return toCart(userId);
    }

    private CartResponse toCart(String userId) {
        List<CartItemResponse> items = carts.find(userId).values().stream()
                .map(item -> new CartItemResponse(item.productId(), item.price(),
                        item.quantity(), item.price().multiply(BigDecimal.valueOf(item.quantity()))))
                .toList();
        return new CartResponse(userId, items, items.stream().map(CartItemResponse::subtotal).reduce(BigDecimal.ZERO, BigDecimal::add),
                items.stream().mapToInt(CartItemResponse::quantity).sum());
    }
}
