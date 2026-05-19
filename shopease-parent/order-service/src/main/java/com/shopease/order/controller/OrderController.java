package com.shopease.order.controller;

import lombok.RequiredArgsConstructor;

import com.shopease.common.dto.ApiResponse;
import com.shopease.order.dto.CreateOrderRequest;
import com.shopease.order.dto.OrderResponse;
import com.shopease.order.dto.PaymentStatusRequest;
import com.shopease.order.dto.ReviewEligibilityResponse;
import com.shopease.order.service.OrderService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {
    private final OrderService orders;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    ApiResponse<OrderResponse> place(@RequestHeader(value = "X-User-Id", defaultValue = "demo-buyer") String buyerId,
                                     @Valid @RequestBody CreateOrderRequest request) {
        return ApiResponse.created(orders.place(buyerId, request));
    }

    @GetMapping
    ApiResponse<List<OrderResponse>> all(@RequestHeader(value = "X-User-Id", defaultValue = "demo-buyer") String buyerId) {
        return ApiResponse.ok(orders.byBuyer(buyerId));
    }

    @GetMapping("/{id}")
    ApiResponse<OrderResponse> one(@PathVariable UUID id) {
        return ApiResponse.ok(orders.one(id));
    }

    @PostMapping("/{id}/cancel")
    ApiResponse<OrderResponse> cancel(@PathVariable UUID id) {
        return ApiResponse.ok(orders.cancel(id));
    }

    @PostMapping("/{id}/payment-status")
    ApiResponse<OrderResponse> paymentStatus(@PathVariable UUID id,
                                             @Valid @RequestBody PaymentStatusRequest request) {
        return ApiResponse.ok(orders.updatePaymentStatus(id, request.paid()));
    }

    @PostMapping("/{id}/deliver")
    ApiResponse<OrderResponse> deliver(@PathVariable UUID id) {
        return ApiResponse.ok(orders.deliver(id));
    }

    @GetMapping("/{id}/review-eligibility")
    ApiResponse<ReviewEligibilityResponse> reviewEligibility(
            @PathVariable UUID id,
            @RequestHeader(value = "X-User-Id", defaultValue = "demo-buyer") String buyerId,
            @RequestParam Long productId) {
        return ApiResponse.ok(orders.reviewEligibility(id, buyerId, productId));
    }
}
