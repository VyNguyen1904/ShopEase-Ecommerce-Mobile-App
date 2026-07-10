package com.shopease.order;

import com.shopease.common.domain.OrderStatus;
import com.shopease.common.domain.PaymentStatus;
import com.shopease.order.model.Order;
import com.shopease.order.model.OrderItem;
import com.shopease.order.repository.OrderRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.UUID;

@SpringBootApplication
public class OrderServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(OrderServiceApplication.class, args);
    }

    @Bean
    CommandLineRunner seedOrders(OrderRepository orderRepository) {
        return args -> {
            if (orderRepository.count() == 0) {
                Instant now = Instant.now();
                
                // 6 days ago
                Order o1 = new Order(
                    UUID.randomUUID(), "buyer-demo-1", OrderStatus.DELIVERED, PaymentStatus.PAID,
                    List.of(new OrderItem(1L, "Nike Air Max 270", "nike.jpg", new BigDecimal("160.00"), 1, new BigDecimal("160.00"), "seller-demo")),
                    new BigDecimal("160.00"), new BigDecimal("10.00"), BigDecimal.ZERO, new BigDecimal("170.00"),
                    "COD", "Recipient 1", "+84900000001", "Street 1", "District 1", "City 1", null, null, "Note 1", now.minus(6, ChronoUnit.DAYS)
                );

                // 5 days ago
                Order o2 = new Order(
                    UUID.randomUUID(), "buyer-demo-2", OrderStatus.DELIVERED, PaymentStatus.PAID,
                    List.of(new OrderItem(2L, "Adidas Ultraboost", "adidas.jpg", new BigDecimal("180.00"), 2, new BigDecimal("360.00"), "seller-demo")),
                    new BigDecimal("360.00"), new BigDecimal("10.00"), BigDecimal.ZERO, new BigDecimal("370.00"),
                    "Credit Card", "Recipient 2", "+84900000002", "Street 2", "District 2", "City 2", null, null, "Note 2", now.minus(5, ChronoUnit.DAYS)
                );

                // 3 days ago
                Order o3 = new Order(
                    UUID.randomUUID(), "buyer-demo-3", OrderStatus.DELIVERED, PaymentStatus.PAID,
                    List.of(new OrderItem(3L, "Puma RS-X", "puma.jpg", new BigDecimal("118.00"), 1, new BigDecimal("118.00"), "seller-demo")),
                    new BigDecimal("118.00"), new BigDecimal("10.00"), BigDecimal.ZERO, new BigDecimal("128.00"),
                    "Credit Card", "Recipient 3", "+84900000003", "Street 3", "District 3", "City 3", null, null, "Note 3", now.minus(3, ChronoUnit.DAYS)
                );

                // 2 days ago
                Order o4 = new Order(
                    UUID.randomUUID(), "buyer-demo-4", OrderStatus.DELIVERED, PaymentStatus.PAID,
                    List.of(new OrderItem(4L, "Converse Chuck 70", "converse.jpg", new BigDecimal("98.00"), 1, new BigDecimal("98.00"), "seller-demo")),
                    new BigDecimal("98.00"), new BigDecimal("10.00"), BigDecimal.ZERO, new BigDecimal("108.00"),
                    "COD", "Recipient 4", "+84900000004", "Street 4", "District 4", "City 4", null, null, "Note 4", now.minus(2, ChronoUnit.DAYS)
                );

                // 1 day ago
                Order o5 = new Order(
                    UUID.randomUUID(), "buyer-demo-5", OrderStatus.DELIVERED, PaymentStatus.PAID,
                    List.of(new OrderItem(1L, "Nike Air Max 270", "nike.jpg", new BigDecimal("160.00"), 1, new BigDecimal("160.00"), "seller-demo")),
                    new BigDecimal("160.00"), new BigDecimal("10.00"), BigDecimal.ZERO, new BigDecimal("170.00"),
                    "COD", "Recipient 5", "+84900000005", "Street 5", "District 5", "City 5", null, null, "Note 5", now.minus(1, ChronoUnit.DAYS)
                );

                orderRepository.saveAll(List.of(o1, o2, o3, o4, o5));
            }
        };
    }
}
