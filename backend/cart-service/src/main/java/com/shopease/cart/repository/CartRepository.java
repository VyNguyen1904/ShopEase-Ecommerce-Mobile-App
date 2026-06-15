package com.shopease.cart.repository;

import lombok.RequiredArgsConstructor;

import com.shopease.cart.model.CartItem;
import org.springframework.stereotype.Repository;
import org.springframework.data.redis.core.HashOperations;
import org.springframework.data.redis.core.RedisTemplate;

import java.util.LinkedHashMap;
import java.util.Map;

@Repository
@RequiredArgsConstructor
public class CartRepository {
    private static final String KEY_PREFIX = "cart:";
    private final HashOperations<String, String, CartItem> carts;



    public Map<String, CartItem> find(String userId) {
        return new LinkedHashMap<>(carts.entries(key(userId)));
    }

    public void put(String userId, String itemId, CartItem item) {
        carts.put(key(userId), itemId, item);
    }

    public void remove(String userId, String itemId) {
        carts.delete(key(userId), itemId);
    }

    public void clear(String userId) {
        carts.getOperations().delete(key(userId));
    }

    private String key(String userId) {
        return KEY_PREFIX + userId;
    }
}
