package com.shopease.payment.controller;

import com.shopease.common.dto.ApiResponse;
import com.shopease.payment.dto.PaymentDtos.CreatePaymentRequest;
import com.shopease.payment.dto.PaymentDtos.PaymentResponse;
import com.shopease.payment.dto.PaymentDtos.RefundRequest;
import com.shopease.payment.dto.PaymentDtos.RefundResponse;
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
    ApiResponse<PaymentResponse> create(@Valid @RequestBody CreatePaymentRequest request) {
        return ApiResponse.created(payments.create(request));
    }

    @GetMapping
    ApiResponse<List<PaymentResponse>> all() {
        return ApiResponse.ok(payments.all());
    }

    @GetMapping("/orders/{orderId}")
    ApiResponse<PaymentResponse> byOrder(@PathVariable UUID orderId) {
        return ApiResponse.ok(payments.byOrder(orderId));
    }

    @PostMapping("/orders/{orderId}/simulate")
    ApiResponse<PaymentResponse> simulate(@PathVariable UUID orderId,
                                          @RequestParam(defaultValue = "true") boolean success) {
        return ApiResponse.ok(payments.simulate(orderId, success));
    }

    @PostMapping("/{id}/refund")
    ApiResponse<RefundResponse> refund(@PathVariable UUID id, @Valid @RequestBody RefundRequest request) {
        return ApiResponse.ok(payments.refund(id, request));
    }
}
