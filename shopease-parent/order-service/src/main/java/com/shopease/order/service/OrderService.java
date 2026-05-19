package com.shopease.order.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import com.shopease.order.client.InventoryClient;
import com.shopease.order.client.PaymentClient;
import com.shopease.order.dto.OrderDTO.CreateOrderRequest;
import com.shopease.order.dto.OrderDTO.OrderResponse;
import com.shopease.order.dto.OrderDTO.ReviewEligibilityResponse;
import com.shopease.order.client.ProductCatalogClient;
import com.shopease.order.model.Order;
import com.shopease.order.model.OrderItem;
import com.shopease.order.model.ProductSnapshot;
import com.shopease.order.repository.OrderRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
@Slf4j
public class OrderService {
    private final OrderRepository orders;
    private final ProductCatalogClient products;
    private final InventoryClient inventory;
    private final PaymentClient payments;


    @Transactional
    public OrderResponse place(String buyerId, CreateOrderRequest request) {
        List<OrderItem> items = request.items().stream().map(item -> {
            ProductSnapshot product = products.find(item.productId());
            return new OrderItem(product.productId(), product.name(), product.imageUrl(), product.price(), item.quantity(),
                    product.price().multiply(BigDecimal.valueOf(item.quantity())));
        }).toList();
        BigDecimal subtotal = items.stream().map(OrderItem::getSubtotal).reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal shipping = subtotal.compareTo(new BigDecimal("500000")) >= 0 ? BigDecimal.ZERO : new BigDecimal("25000");
        String paymentMethod = request.paymentMethod() == null ? "COD" : request.paymentMethod().trim().toUpperCase(Locale.ROOT);
        List<OrderItem> reservedItems = new ArrayList<>();
        try {
            reserveItems(items, reservedItems);
            Order order = new Order(UUID.randomUUID(), buyerId, "PENDING", "UNPAID", items, subtotal, shipping,
                    BigDecimal.ZERO, subtotal.add(shipping), paymentMethod, request.shipRecipient(), request.shipPhone(),
                    request.shipStreet(), request.shipDistrict(), request.shipCity(), request.note(), Instant.now());
            Order saved = orders.saveAndFlush(order);
            payments.create(saved.getId(), buyerId, saved.getTotalAmount(), paymentMethod);
            return OrderResponse.from(saved);
        } catch (RuntimeException ex) {
            releaseItemsQuietly(reservedItems);
            throw ex;
        }
    }

    public List<OrderResponse> byBuyer(String buyerId) {
        return orders.findByBuyerIdOrderByCreatedAtDesc(buyerId).stream().map(OrderResponse::from).toList();
    }

    public OrderResponse one(UUID id) {
        return OrderResponse.from(requireOrder(id));
    }

    @Transactional
    public OrderResponse cancel(UUID id) {
        Order order = requireOrder(id);
        if ("DELIVERED".equals(order.getStatus())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Delivered orders cannot be cancelled");
        }
        if (order.hasReleasableInventory()) {
            releaseItems(order.getItems());
        }
        order.cancel();
        Order saved = orders.save(order);
        return OrderResponse.from(saved);
    }

    @Transactional
    public OrderResponse updatePaymentStatus(UUID id, boolean paid) {
        Order order = requireOrder(id);
        if (paid) {
            if ("CANCELLED".equals(order.getStatus()) || "PAYMENT_FAILED".equals(order.getStatus())) {
                throw new ResponseStatusException(HttpStatus.CONFLICT,
                        "Cannot mark a cancelled or payment-failed order as paid");
            }
            order.markPaymentPaid();
        } else {
            if ("PAID".equals(order.getPaymentStatus()) || "DELIVERED".equals(order.getStatus())) {
                throw new ResponseStatusException(HttpStatus.CONFLICT,
                        "Cannot mark a paid or delivered order as payment failed");
            }
            if (order.hasReleasableInventory()) {
                releaseItems(order.getItems());
            }
            order.markPaymentFailed();
        }
        Order saved = orders.save(order);
        return OrderResponse.from(saved);
    }

    @Transactional
    public OrderResponse deliver(UUID id) {
        Order order = requireOrder(id);
        if (!order.hasFulfillableInventory()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Only pending or confirmed orders can be delivered");
        }
        commitItems(order.getItems());
        order.markDelivered();
        Order saved = orders.save(order);
        return OrderResponse.from(saved);
    }

    public ReviewEligibilityResponse reviewEligibility(UUID id, String buyerId, Long productId) {
        Order order = requireOrder(id);
        if (!order.getBuyerId().equals(buyerId)) {
            return new ReviewEligibilityResponse(order.getId(), buyerId, productId, false,
                    "Order does not belong to buyer");
        }
        if (!"DELIVERED".equals(order.getStatus())) {
            return new ReviewEligibilityResponse(order.getId(), buyerId, productId, false,
                    "Order must be delivered before review");
        }
        boolean containsProduct = order.getItems().stream()
                .anyMatch(item -> item.getProductId().equals(productId));
        if (!containsProduct) {
            return new ReviewEligibilityResponse(order.getId(), buyerId, productId, false,
                    "Product was not part of this order");
        }
        return new ReviewEligibilityResponse(order.getId(), buyerId, productId, true, "Eligible");
    }

    private Order requireOrder(UUID id) {
        return orders.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Order not found"));
    }

    private void reserveItems(List<OrderItem> items, List<OrderItem> reservedItems) {
        for (OrderItem item : items) {
            inventory.reserve(item.getProductId(), item.getQuantity());
            reservedItems.add(item);
        }
    }

    private void releaseItems(List<OrderItem> items) {
        for (OrderItem item : items) {
            inventory.release(item.getProductId(), item.getQuantity());
        }
    }

    private void commitItems(List<OrderItem> items) {
        for (OrderItem item : items) {
            inventory.commit(item.getProductId(), item.getQuantity());
        }
    }

    private void releaseItemsQuietly(List<OrderItem> items) {
        for (OrderItem item : items) {
            try {
                inventory.release(item.getProductId(), item.getQuantity());
            } catch (RuntimeException releaseFailure) {
                log.warn("Failed to release reserved stock for product {} after order placement failure",
                        item.getProductId(), releaseFailure);
            }
        }
    }
}
