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
        Map<String, CartItem> cart = carts.find(userId);
        String itemId = generateItemId(request.productId(), request.color(), request.size());
        CartItem existing = cart.get(itemId);
        int quantity = request.quantity() + (existing == null ? 0 : existing.quantity());
        carts.put(userId, itemId, new CartItem(request.productId(), price, quantity, request.color(), request.size(), Instant.now()));
        return toCart(userId);
    }

    public CartResponse updateItemQuantity(String userId, String itemId, CartItemRequest request) {
        BigDecimal price = products.getProductPrice(request.productId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Product " + request.productId() + " not found"));
        carts.put(userId, itemId, new CartItem(request.productId(), price, request.quantity(), request.color(), request.size(), Instant.now()));
        return toCart(userId);
    }

    public CartResponse removeItemFromCart(String userId, String itemId) {
        carts.remove(userId, itemId);
        return toCart(userId);
    }

    public CartResponse clearCart(String userId) {
        carts.clear(userId);
        return toCart(userId);
    }

    private CartResponse toCart(String userId) {
        List<CartItemResponse> items = carts.find(userId).entrySet().stream()
                .map(entry -> {
                    CartItem item = entry.getValue();
                    return new CartItemResponse(entry.getKey(), item.productId(), item.color(), item.size(), item.price(),
                            item.quantity(), item.price().multiply(BigDecimal.valueOf(item.quantity())));
                })
                .toList();
        return new CartResponse(userId, items, items.stream().map(CartItemResponse::subtotal).reduce(BigDecimal.ZERO, BigDecimal::add),
                items.stream().mapToInt(CartItemResponse::quantity).sum());
    }

    private String generateItemId(Long productId, String color, String size) {
        return productId + "_" + (color != null ? color : "null") + "_" + (size != null ? size : "null");
    }
}
