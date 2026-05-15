package com.shopease.order.service;

import com.shopease.order.dto.OrderDtos.CreateOrderRequest;
<<<<<<< HEAD
import com.shopease.order.client.ProductCatalogClient;
=======
>>>>>>> 9f2b30358e4062f0be39eb86dfe53ada7c670722
import com.shopease.order.model.Order;
import com.shopease.order.model.OrderItem;
import com.shopease.order.model.ProductSnapshot;
import com.shopease.order.repository.OrderRepository;
<<<<<<< HEAD
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
=======
import com.shopease.order.repository.ProductSnapshotRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
>>>>>>> 9f2b30358e4062f0be39eb86dfe53ada7c670722
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
<<<<<<< HEAD
@Transactional
public class OrderService {
    private final OrderRepository orders;
    private final ProductCatalogClient products;

    public OrderService(OrderRepository orders, ProductCatalogClient products) {
=======
public class OrderService {
    private final OrderRepository orders;
    private final ProductSnapshotRepository products;

    public OrderService(OrderRepository orders, ProductSnapshotRepository products) {
>>>>>>> 9f2b30358e4062f0be39eb86dfe53ada7c670722
        this.orders = orders;
        this.products = products;
    }

    public Order place(String buyerId, CreateOrderRequest request) {
        List<OrderItem> items = request.items().stream().map(item -> {
            ProductSnapshot product = products.find(item.productId());
            return new OrderItem(product.productId(), product.name(), product.imageUrl(), product.price(), item.quantity(),
                    product.price().multiply(BigDecimal.valueOf(item.quantity())));
        }).toList();
<<<<<<< HEAD
        BigDecimal subtotal = items.stream().map(OrderItem::getSubtotal).reduce(BigDecimal.ZERO, BigDecimal::add);
=======
        BigDecimal subtotal = items.stream().map(OrderItem::subtotal).reduce(BigDecimal.ZERO, BigDecimal::add);
>>>>>>> 9f2b30358e4062f0be39eb86dfe53ada7c670722
        BigDecimal shipping = subtotal.compareTo(new BigDecimal("500000")) >= 0 ? BigDecimal.ZERO : new BigDecimal("25000");
        return orders.save(new Order(UUID.randomUUID(), buyerId, "PENDING", "UNPAID", items, subtotal, shipping,
                BigDecimal.ZERO, subtotal.add(shipping), request.paymentMethod() == null ? "COD" : request.paymentMethod(),
                request.shipRecipient(), request.shipPhone(), request.shipStreet(), request.shipDistrict(),
                request.shipCity(), request.note(), Instant.now()));
    }

    public List<Order> byBuyer(String buyerId) {
<<<<<<< HEAD
        return orders.findByBuyerIdOrderByCreatedAtDesc(buyerId);
=======
        return orders.findByBuyerId(buyerId);
>>>>>>> 9f2b30358e4062f0be39eb86dfe53ada7c670722
    }

    public Order one(UUID id) {
        return orders.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Order not found"));
    }

    public Order cancel(UUID id) {
<<<<<<< HEAD
        Order order = one(id);
        order.cancel();
        return orders.save(order);
=======
        return orders.save(one(id).cancelled());
>>>>>>> 9f2b30358e4062f0be39eb86dfe53ada7c670722
    }
}
