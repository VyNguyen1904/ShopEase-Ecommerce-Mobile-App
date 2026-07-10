package com.shopease.order.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import com.shopease.common.domain.OrderStatus;
import com.shopease.common.domain.PaymentStatus;
import com.shopease.common.event.DomainEvents.*;
import com.shopease.order.client.ProductCatalogClient;
import com.shopease.order.dto.CreateOrderRequest;
import com.shopease.order.dto.NotificationEvent;
import com.shopease.order.dto.OrderResponse;
import com.shopease.order.dto.ReviewEligibilityResponse;
import com.shopease.order.model.Order;
import com.shopease.order.model.OrderItem;
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
@Slf4j
@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
public class OrderService {
    private final OrderRepository orders;
    private final ProductCatalogClient productCatalog;
    private final KafkaTemplate<String, Object> kafkaTemplate;

    @Transactional
    public OrderResponse createOrder(String buyerId, CreateOrderRequest request) {
        List<OrderItem> items = request.items().stream().map(item -> {
            ProductCatalogClient.ProductResponse product = productCatalog.getProduct(item.productId());
            BigDecimal price = product.salePrice() != null ? product.salePrice() : product.basePrice();
            return new OrderItem(item.productId(), product.name(), product.thumbnailUrl(), price, item.quantity(),
                    price.multiply(BigDecimal.valueOf(item.quantity())), product.sellerId(), item.color(), item.size());
        }).toList();

        BigDecimal subtotal = items.stream().map(OrderItem::getSubtotal).reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal shipping = subtotal.compareTo(new BigDecimal("500000")) >= 0 ? BigDecimal.ZERO : new BigDecimal("25000");
        String paymentMethod = request.paymentMethod() == null ? "COD" : request.paymentMethod().trim().toUpperCase(Locale.ROOT);

        Order order = new Order(UUID.randomUUID(), buyerId, OrderStatus.PENDING, PaymentStatus.UNPAID, items, subtotal, shipping,
                BigDecimal.ZERO, subtotal.add(shipping), paymentMethod, request.shipRecipient(), request.shipPhone(),
                request.shipStreet(), request.shipDistrict(), request.shipCity(), request.shipLatitude(), request.shipLongitude(), request.note(), Instant.now());
        
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

    public List<OrderResponse> getOrderHistory(String buyerId) {
        return orders.findByBuyerIdOrderByCreatedAtDesc(buyerId).stream().map(OrderResponse::from).toList();
    }

    public List<OrderResponse> getOrdersForSeller(String sellerId) {
        return orders.findBySellerId(sellerId).stream().map(OrderResponse::from).toList();
    }

    public OrderResponse getOrderDetail(UUID id, String userId, String userRole) {
        Order order = requireOrder(id);
        if (!"ADMIN".equalsIgnoreCase(userRole)) {
            boolean isBuyer = order.getBuyerId().equals(userId);
            boolean isSeller = order.getItems().stream()
                    .anyMatch(item -> item.getSellerId().equals(userId));
            if (!isBuyer && !isSeller) {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Access denied to order details");
            }
        }
        return OrderResponse.from(order);
    }

    @Transactional
    public OrderResponse cancelOrder(UUID id, String userId, String userRole) {
        Order order = requireOrder(id);
        if (!"ADMIN".equalsIgnoreCase(userRole) && !order.getBuyerId().equals(userId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Access denied to cancel this order");
        }
        if (OrderStatus.DELIVERED.equals(order.getStatus())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Delivered orders cannot be cancelled");
        }
        
        order.cancel();
        Order saved = orders.save(order);
        
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
    public OrderResponse markAsDelivered(UUID id, String userId, String userRole) {
        Order order = requireOrder(id);
        if (!"ADMIN".equalsIgnoreCase(userRole)) {
            boolean isBuyer = order.getBuyerId().equals(userId);
            boolean isSeller = order.getItems().stream()
                    .anyMatch(item -> item.getSellerId().equals(userId));
            if (!isBuyer && !isSeller) {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the buyer or seller can mark this order as delivered");
            }
        }
        order.markDelivered();

        NotificationEvent event = new NotificationEvent(order.getBuyerId(), "Giao hàng thành công", "Đơn hàng " + id.toString().substring(0, 8) + " của bạn đã được giao thành công.", "ORDER_UPDATE");
        kafkaTemplate.send("notification-events", order.getBuyerId(), event);

        return OrderResponse.from(orders.save(order));
    }

    @Transactional
    public OrderResponse confirmOrder(UUID id, String userId, String userRole) {
        Order order = requireOrder(id);
        requireSellerOrAdmin(order, userId, userRole, "confirm");
        order.markConfirmed();
        
        NotificationEvent event = new NotificationEvent(order.getBuyerId(), "Đơn hàng đã được xác nhận", "Đơn hàng " + id.toString().substring(0, 8) + " của bạn đã được người bán xác nhận.", "ORDER_UPDATE");
        kafkaTemplate.send("notification-events", order.getBuyerId(), event);
        
        return OrderResponse.from(orders.save(order));
    }

    @Transactional
    public OrderResponse packOrder(UUID id, String userId, String userRole) {
        Order order = requireOrder(id);
        requireSellerOrAdmin(order, userId, userRole, "pack");
        order.markPacked();

        NotificationEvent event = new NotificationEvent(order.getBuyerId(), "Đơn hàng đang được chuẩn bị", "Đơn hàng " + id.toString().substring(0, 8) + " của bạn đang được đóng gói.", "ORDER_UPDATE");
        kafkaTemplate.send("notification-events", order.getBuyerId(), event);

        return OrderResponse.from(orders.save(order));
    }

    @Transactional
    public OrderResponse shipOrder(UUID id, String userId, String userRole) {
        Order order = requireOrder(id);
        requireSellerOrAdmin(order, userId, userRole, "ship");
        order.markShipped();

        NotificationEvent event = new NotificationEvent(order.getBuyerId(), "Đơn hàng đang giao", "Đơn hàng " + id.toString().substring(0, 8) + " của bạn đã được giao cho đơn vị vận chuyển.", "ORDER_UPDATE");
        kafkaTemplate.send("notification-events", order.getBuyerId(), event);

        return OrderResponse.from(orders.save(order));
    }

    private void requireSellerOrAdmin(Order order, String userId, String userRole, String action) {
        if (!"ADMIN".equalsIgnoreCase(userRole)) {
            boolean isSellerOfOrderItem = order.getItems().stream()
                    .anyMatch(item -> item.getSellerId().equals(userId));
            if (!isSellerOfOrderItem) {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the seller of the items in this order can " + action + " it");
            }
        }
    }

    public ReviewEligibilityResponse checkReviewEligibility(UUID id, String buyerId, Long productId) {
        Order order = requireOrder(id);
        if (!order.getBuyerId().equals(buyerId)) {
            return new ReviewEligibilityResponse(order.getId(), buyerId, productId, false,
                    "Order does not belong to buyer");
        }
        if (!OrderStatus.DELIVERED.equals(order.getStatus())) {
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
        return new OrderItemEvent(item.getProductId(), item.getQuantity());
    }
}
