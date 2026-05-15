package com.shopease.cart.repository;

import com.shopease.cart.model.CartItem;
import org.springframework.stereotype.Repository;
import org.springframework.data.redis.core.HashOperations;
import org.springframework.data.redis.core.RedisTemplate;

import java.util.LinkedHashMap;
import java.util.Map;

@Repository
public class CartRepository {
    private static final String KEY_PREFIX = "cart:";
    private final HashOperations<String, Long, CartItem> carts;

    public CartRepository(RedisTemplate<String, CartItem> redisTemplate) {
        this.carts = redisTemplate.opsForHash();
    }

    public Map<Long, CartItem> find(String userId) {
        return new LinkedHashMap<>(carts.entries(key(userId)));
    }

    public void put(String userId, CartItem item) {
        carts.put(key(userId), item.productId(), item);
    }

    public void remove(String userId, Long productId) {
        carts.delete(key(userId), productId);
    }

    public void clear(String userId) {
        carts.getOperations().delete(key(userId));
    }

    private String key(String userId) {
        return KEY_PREFIX + userId;
    }
}
