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
    ApiResponse<OrderResponse> createOrder(@RequestHeader(value = "X-User-Id", defaultValue = "demo-buyer") String buyerId,
                                           @Valid @RequestBody CreateOrderRequest request) {
        return ApiResponse.created(orders.createOrder(buyerId, request));
    }

    @GetMapping
    ApiResponse<List<OrderResponse>> getOrderHistory(@RequestHeader(value = "X-User-Id", defaultValue = "demo-buyer") String buyerId) {
        return ApiResponse.ok(orders.getOrderHistory(buyerId));
    }

    @GetMapping("/{id}")
    ApiResponse<OrderResponse> getOrderDetail(@PathVariable UUID id) {
        return ApiResponse.ok(orders.getOrderDetail(id));
    }

    @PostMapping("/{id}/cancel")
    ApiResponse<OrderResponse> cancelOrder(@PathVariable UUID id) {
        return ApiResponse.ok(orders.cancelOrder(id));
    }

    @PostMapping("/{id}/payment-status")
    ApiResponse<OrderResponse> updatePaymentStatus(@PathVariable UUID id,
                                                   @Valid @RequestBody PaymentStatusRequest request) {
        return ApiResponse.ok(orders.updatePaymentStatus(id, request.paid()));
    }

    @PostMapping("/{id}/deliver")
    ApiResponse<OrderResponse> markAsDelivered(@PathVariable UUID id) {
        return ApiResponse.ok(orders.markAsDelivered(id));
    }

    @GetMapping("/{id}/review-eligibility")
    ApiResponse<ReviewEligibilityResponse> checkReviewEligibility(
            @PathVariable UUID id,
            @RequestHeader(value = "X-User-Id", defaultValue = "demo-buyer") String buyerId,
            @RequestParam Long productId) {
        return ApiResponse.ok(orders.checkReviewEligibility(id, buyerId, productId));
    }
}
