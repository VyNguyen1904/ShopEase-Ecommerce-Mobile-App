package com.shopease.order.repository;

import com.shopease.order.model.Order;
<<<<<<< HEAD
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface OrderRepository extends JpaRepository<Order, UUID> {
    List<Order> findByBuyerIdOrderByCreatedAtDesc(String buyerId);
=======
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Repository
public class OrderRepository {
    private final Map<UUID, Order> orders = new ConcurrentHashMap<>();

    public Order save(Order order) {
        orders.put(order.id(), order);
        return order;
    }

    public Optional<Order> findById(UUID id) {
        return Optional.ofNullable(orders.get(id));
    }

    public List<Order> findByBuyerId(String buyerId) {
        return orders.values().stream().filter(order -> order.buyerId().equals(buyerId)).toList();
    }
>>>>>>> 9f2b30358e4062f0be39eb86dfe53ada7c670722
}
