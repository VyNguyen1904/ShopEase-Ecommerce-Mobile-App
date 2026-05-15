package com.shopease.order.controller;

import com.shopease.common.dto.ApiResponse;
import com.shopease.order.dto.OrderDtos.CreateOrderRequest;
import com.shopease.order.dto.OrderDtos.OrderResponse;
import com.shopease.order.service.OrderService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/orders")
public class OrderController {
    private final OrderService orders;

    public OrderController(OrderService orders) {
        this.orders = orders;
    }

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
}
