package com.shopease.payment.repository;

import com.shopease.payment.model.PaymentTransaction;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Repository
public class PaymentRepository {
    private final Map<UUID, PaymentTransaction> payments = new ConcurrentHashMap<>();

    public PaymentTransaction save(PaymentTransaction payment) {
        payments.put(payment.id(), payment);
        return payment;
    }

    public Optional<PaymentTransaction> findById(UUID id) {
        return Optional.ofNullable(payments.get(id));
    }

    public Optional<PaymentTransaction> findByOrderId(UUID orderId) {
        return payments.values().stream().filter(payment -> payment.orderId().equals(orderId)).findFirst();
    }

    public List<PaymentTransaction> findAll() {
        return payments.values().stream().toList();
    }
}
