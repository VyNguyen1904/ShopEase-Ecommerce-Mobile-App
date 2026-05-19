package com.shopease.order.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import com.shopease.common.event.DomainEvents.*;
import com.shopease.order.client.ProductCatalogClient;
import com.shopease.order.dto.CreateOrderRequest;
import com.shopease.order.dto.OrderResponse;
import com.shopease.order.dto.ReviewEligibilityResponse;
import com.shopease.order.model.Order;
import com.shopease.order.model.OrderItem;
import com.shopease.order.model.ProductSnapshot;
import com.shopease.order.repository.OrderRepository;
import org.springframework.http.HttpStatus;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
@Slf4j
public class OrderService {
    private final OrderRepository orders;
    private final ProductCatalogClient productCatalog;
    private final KafkaTemplate<String, Object> kafkaTemplate;

    @Transactional
    public OrderResponse place(String buyerId, CreateOrderRequest request) {
        // Synchronous validation and snapshotting
        List<OrderItem> items = request.items().stream().map(item -> {
            ProductSnapshot product = productCatalog.find(item.productId());
            return new OrderItem(product.productId(), product.name(), product.imageUrl(), product.price(), item.quantity(),
                    product.price().multiply(BigDecimal.valueOf(item.quantity())));
        }).toList();

        BigDecimal subtotal = items.stream().map(OrderItem::getSubtotal).reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal shipping = subtotal.compareTo(new BigDecimal("500000")) >= 0 ? BigDecimal.ZERO : new BigDecimal("25000");
        String paymentMethod = request.paymentMethod() == null ? "COD" : request.paymentMethod().trim().toUpperCase(Locale.ROOT);

        Order order = new Order(UUID.randomUUID(), buyerId, "PENDING", "UNPAID", items, subtotal, shipping,
                BigDecimal.ZERO, subtotal.add(shipping), paymentMethod, request.shipRecipient(), request.shipPhone(),
                request.shipStreet(), request.shipDistrict(), request.shipCity(), request.note(), Instant.now());
        
        Order saved = orders.saveAndFlush(order);

        // Start Saga: Reserve Stock
        ReserveStockCommand command = new ReserveStockCommand(
                saved.getId(),
                items.stream().map(this::toEventItem).toList(),
                Instant.now()
        );
        kafkaTemplate.send("inventory-commands", command.orderId().toString(), command);

        return OrderResponse.from(saved);
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
        
        // In Saga, cancellation should probably also be asynchronous if it involves inventory release
        // but for now, we'll keep it simple or trigger a compensation command.
        
        order.cancel();
        Order saved = orders.save(order);
        
        // Trigger compensation if needed
        CompensateInventoryCommand command = new CompensateInventoryCommand(
                saved.getId(),
                saved.getItems().stream().map(this::toEventItem).toList(),
                Instant.now()
        );
        kafkaTemplate.send("inventory-commands", command.orderId().toString(), command);

        return OrderResponse.from(saved);
    }

    @Transactional
    public OrderResponse updatePaymentStatus(UUID id, boolean paid) {
        Order order = requireOrder(id);
        if (paid) {
            order.markPaymentPaid();
        } else {
            order.markPaymentFailed();
        }
        return OrderResponse.from(orders.save(order));
    }

    @Transactional
    public OrderResponse deliver(UUID id) {
        Order order = requireOrder(id);
        order.markDelivered();
        return OrderResponse.from(orders.save(order));
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

    private OrderItemEvent toEventItem(OrderItem item) {
        return new OrderItemEvent(item.getProductId(), item.getProductName(), item.getQuantity(), item.getUnitPrice());
    }
}
