package com.shopease.order.repository;

import com.shopease.order.model.Order;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface OrderRepository extends JpaRepository<Order, UUID> {
    List<Order> findByBuyerIdOrderByCreatedAtDesc(String buyerId);

    @org.springframework.data.jpa.repository.Query("SELECT DISTINCT o FROM Order o JOIN o.items i WHERE i.sellerId = :sellerId ORDER BY o.createdAt DESC")
    List<Order> findBySellerId(String sellerId);

    List<Order> findByStatusAndPaymentStatusAndCreatedAtBefore(com.shopease.common.domain.OrderStatus status, com.shopease.common.domain.PaymentStatus paymentStatus, java.time.Instant cutoffTime);
}
