package com.shopease.payment.service;

import com.shopease.payment.dto.PaymentDtos.CreatePaymentRequest;
import com.shopease.payment.dto.PaymentDtos.RefundRequest;
import com.shopease.payment.model.PaymentTransaction;
import com.shopease.payment.model.Refund;
import com.shopease.payment.repository.PaymentRepository;
<<<<<<< HEAD
import com.shopease.payment.repository.RefundRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
=======
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
>>>>>>> 9f2b30358e4062f0be39eb86dfe53ada7c670722
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
<<<<<<< HEAD
@Transactional
public class PaymentService {
    private final PaymentRepository payments;
    private final RefundRepository refunds;

    public PaymentService(PaymentRepository payments, RefundRepository refunds) {
        this.payments = payments;
        this.refunds = refunds;
=======
public class PaymentService {
    private final PaymentRepository payments;

    public PaymentService(PaymentRepository payments) {
        this.payments = payments;
>>>>>>> 9f2b30358e4062f0be39eb86dfe53ada7c670722
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
<<<<<<< HEAD
        if (success) {
            current.markCompleted();
        } else {
            current.markFailed();
        }
        return payments.save(current);
=======
        return payments.save(success ? current.completed() : current.failed());
>>>>>>> 9f2b30358e4062f0be39eb86dfe53ada7c670722
    }

    public Refund refund(UUID transactionId, RefundRequest request) {
        payments.findById(transactionId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Payment not found"));
<<<<<<< HEAD
        return refunds.save(new Refund(UUID.randomUUID(), transactionId, request.amount(), request.reason(), "COMPLETED", Instant.now()));
=======
        return new Refund(UUID.randomUUID(), transactionId, request.amount(), request.reason(), "COMPLETED", Instant.now());
>>>>>>> 9f2b30358e4062f0be39eb86dfe53ada7c670722
    }
}
