package com.shopease.payment.service;

import com.shopease.payment.dto.PaymentDtos.CreatePaymentRequest;
import com.shopease.payment.dto.PaymentDtos.RefundRequest;
import com.shopease.payment.model.PaymentTransaction;
import com.shopease.payment.model.Refund;
import com.shopease.payment.repository.PaymentRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
public class PaymentService {
    private final PaymentRepository payments;

    public PaymentService(PaymentRepository payments) {
        this.payments = payments;
    }

    public PaymentTransaction create(CreatePaymentRequest request) {
        return payments.save(new PaymentTransaction(UUID.randomUUID(), request.orderId(), request.buyerId(),
                request.amount(), "VND", request.method(), "PENDING", null, null, Instant.now()));
    }

    public List<PaymentTransaction> all() {
        return payments.findAll();
    }

    public PaymentTransaction byOrder(UUID orderId) {
        return payments.findByOrderId(orderId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Payment not found"));
    }

    public PaymentTransaction simulate(UUID orderId, boolean success) {
        PaymentTransaction current = payments.findByOrderId(orderId).orElseGet(() -> payments.save(
                new PaymentTransaction(UUID.randomUUID(), orderId, "demo-buyer", BigDecimal.ZERO, "VND", "COD",
                        "PENDING", null, null, Instant.now())));
        return payments.save(success ? current.completed() : current.failed());
    }

    public Refund refund(UUID transactionId, RefundRequest request) {
        payments.findById(transactionId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Payment not found"));
        return new Refund(UUID.randomUUID(), transactionId, request.amount(), request.reason(), "COMPLETED", Instant.now());
    }
}
