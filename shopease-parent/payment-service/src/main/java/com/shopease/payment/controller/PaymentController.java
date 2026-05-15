package com.shopease.payment.controller;

import com.shopease.common.dto.ApiResponse;
import com.shopease.payment.dto.PaymentDtos.CreatePaymentRequest;
import com.shopease.payment.dto.PaymentDtos.RefundRequest;
import com.shopease.payment.model.PaymentTransaction;
import com.shopease.payment.model.Refund;
import com.shopease.payment.service.PaymentService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/payments")
public class PaymentController {
    private final PaymentService payments;

    public PaymentController(PaymentService payments) {
        this.payments = payments;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    ApiResponse<PaymentTransaction> create(@Valid @RequestBody CreatePaymentRequest request) {
        return ApiResponse.created(payments.create(request));
    }

    @GetMapping
    ApiResponse<List<PaymentTransaction>> all() {
        return ApiResponse.ok(payments.all());
    }

    @GetMapping("/orders/{orderId}")
    ApiResponse<PaymentTransaction> byOrder(@PathVariable UUID orderId) {
        return ApiResponse.ok(payments.byOrder(orderId));
    }

    @PostMapping("/orders/{orderId}/simulate")
    ApiResponse<PaymentTransaction> simulate(@PathVariable UUID orderId,
                                             @RequestParam(defaultValue = "true") boolean success) {
        return ApiResponse.ok(payments.simulate(orderId, success));
    }

    @PostMapping("/{id}/refund")
    ApiResponse<Refund> refund(@PathVariable UUID id, @Valid @RequestBody RefundRequest request) {
        return ApiResponse.ok(payments.refund(id, request));
    }
}
