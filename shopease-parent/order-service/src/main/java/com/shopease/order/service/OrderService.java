package com.shopease.order.service;

import com.shopease.order.dto.OrderDtos.CreateOrderRequest;
import com.shopease.order.dto.OrderDtos.OrderResponse;
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
import java.util.List;
import java.util.UUID;

@Service
@Transactional(readOnly = true)
public class OrderService {
    private final OrderRepository orders;
    private final ProductCatalogClient products;

    public OrderService(OrderRepository orders, ProductCatalogClient products) {
        this.orders = orders;
        this.products = products;
    }

    @Transactional
    public OrderResponse place(String buyerId, CreateOrderRequest request) {
        List<OrderItem> items = request.items().stream().map(item -> {
            ProductSnapshot product = products.find(item.productId());
            return new OrderItem(product.productId(), product.name(), product.imageUrl(), product.price(), item.quantity(),
                    product.price().multiply(BigDecimal.valueOf(item.quantity())));
        }).toList();
        BigDecimal subtotal = items.stream().map(OrderItem::getSubtotal).reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal shipping = subtotal.compareTo(new BigDecimal("500000")) >= 0 ? BigDecimal.ZERO : new BigDecimal("25000");
        return OrderResponse.from(orders.save(new Order(UUID.randomUUID(), buyerId, "PENDING", "UNPAID", items, subtotal, shipping,
                BigDecimal.ZERO, subtotal.add(shipping), request.paymentMethod() == null ? "COD" : request.paymentMethod(),
                request.shipRecipient(), request.shipPhone(), request.shipStreet(), request.shipDistrict(),
                request.shipCity(), request.note(), Instant.now())));
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
        order.cancel();
        return OrderResponse.from(orders.save(order));
    }

    private Order requireOrder(UUID id) {
        return orders.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Order not found"));
    }
}
