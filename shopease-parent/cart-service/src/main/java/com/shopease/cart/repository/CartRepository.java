package com.shopease.cart.repository;

import com.shopease.cart.model.CartItem;
import org.springframework.stereotype.Repository;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Repository
public class CartRepository {
    private final Map<String, Map<Long, CartItem>> carts = new ConcurrentHashMap<>();

    public Map<Long, CartItem> cartFor(String userId) {
        return carts.computeIfAbsent(userId, ignored -> new LinkedHashMap<>());
    }

    public void clear(String userId) {
        carts.remove(userId);
    }
}
