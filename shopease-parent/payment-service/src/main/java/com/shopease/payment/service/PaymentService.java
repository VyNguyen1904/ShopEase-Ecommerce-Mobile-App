package com.shopease.payment.service;

import lombok.RequiredArgsConstructor;

import com.shopease.payment.dto.PaymentDtos.CreatePaymentRequest;
import com.shopease.payment.dto.PaymentDtos.PaymentResponse;
import com.shopease.payment.dto.PaymentDtos.RefundRequest;
import com.shopease.payment.dto.PaymentDtos.RefundResponse;
import com.shopease.payment.model.PaymentTransaction;
import com.shopease.payment.model.Refund;
import com.shopease.payment.repository.PaymentRepository;
import com.shopease.payment.repository.RefundRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
public class PaymentService {
    private final PaymentRepository payments;
    private final RefundRepository refunds;



    @Transactional
    public PaymentResponse create(CreatePaymentRequest request) {
        return PaymentResponse.from(payments.save(new PaymentTransaction(UUID.randomUUID(), request.orderId(), request.buyerId(),
                request.amount(), "VND", request.method(), "PENDING", null, null, Instant.now())));
    }

    public List<PaymentResponse> all() {
        return payments.findAll().stream().map(PaymentResponse::from).toList();
    }

    public PaymentResponse byOrder(UUID orderId) {
        return PaymentResponse.from(payments.findByOrderId(orderId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Payment not found")));
    }

    @Transactional
    public PaymentResponse simulate(UUID orderId, boolean success) {
        PaymentTransaction current = payments.findByOrderId(orderId).orElseGet(() -> payments.save(
                new PaymentTransaction(UUID.randomUUID(), orderId, "demo-buyer", BigDecimal.ZERO, "VND", "COD",
                        "PENDING", null, null, Instant.now())));
        if (success) {
            current.markCompleted();
        } else {
            current.markFailed();
        }
        return PaymentResponse.from(payments.save(current));
    }

    @Transactional
    public RefundResponse refund(UUID transactionId, RefundRequest request) {
        payments.findById(transactionId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Payment not found"));
        return RefundResponse.from(refunds.save(new Refund(UUID.randomUUID(), transactionId, request.amount(), request.reason(), "COMPLETED", Instant.now())));
    }
}
