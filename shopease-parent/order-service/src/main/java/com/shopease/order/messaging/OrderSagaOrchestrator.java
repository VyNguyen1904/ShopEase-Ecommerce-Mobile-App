package com.shopease.order.messaging;

import com.shopease.common.event.DomainEvents.*;
import com.shopease.order.model.Order;
import com.shopease.order.model.OrderItem;
import com.shopease.order.repository.OrderRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Component
@Slf4j
@RequiredArgsConstructor
public class OrderSagaOrchestrator {

    private final KafkaTemplate<String, Object> kafkaTemplate;
    private final OrderRepository orderRepository;

    @Transactional
    @KafkaListener(topics = "inventory-events", groupId = "order-group")
    public void handleInventoryEvents(Object event) {
        if (event instanceof StockReservedEvent e) {
            handleStockReserved(e);
        } else if (event instanceof StockReservationFailedEvent e) {
            handleStockReservationFailed(e);
        }
    }

    @Transactional
    @KafkaListener(topics = "payment-events", groupId = "order-group")
    public void handlePaymentEvents(Object event) {
        if (event instanceof PaymentProcessedEvent e) {
            handlePaymentProcessed(e);
        } else if (event instanceof PaymentFailedEvent e) {
            handlePaymentFailed(e);
        }
    }

    private void handleStockReserved(StockReservedEvent event) {
        log.info("Stock reserved for order {}. Proceeding to payment.", event.orderId());
        orderRepository.findById(event.orderId()).ifPresent(order -> {
            order.setStatus("STOCK_RESERVED");
            orderRepository.save(order);
            
            ProcessPaymentCommand command = new ProcessPaymentCommand(
                    order.getId(),
                    order.getBuyerId(),
                    order.getTotalAmount(),
                    order.getPaymentMethod(),
                    Instant.now()
            );
            kafkaTemplate.send("payment-commands", command.orderId().toString(), command);
        });
    }

    private void handleStockReservationFailed(StockReservationFailedEvent event) {
        log.error("Stock reservation failed for order {}: {}", event.orderId(), event.reason());
        orderRepository.findById(event.orderId()).ifPresent(order -> {
            order.setStatus("FAILED_OUT_OF_STOCK");
            orderRepository.save(order);
            
            OrderFailedEvent failedEvent = new OrderFailedEvent(order.getId(), event.reason(), Instant.now());
            kafkaTemplate.send("order-events", failedEvent.orderId().toString(), failedEvent);
        });
    }

    private void handlePaymentProcessed(PaymentProcessedEvent event) {
        log.info("Payment processed for order {}. Confirming order.", event.orderId());
        orderRepository.findById(event.orderId()).ifPresent(order -> {
            order.markPaymentPaid();
            order.setStatus("CONFIRMED");
            orderRepository.save(order);
            
            OrderConfirmedEvent confirmedEvent = new OrderConfirmedEvent(order.getId(), Instant.now());
            kafkaTemplate.send("order-events", confirmedEvent.orderId().toString(), confirmedEvent);
        });
    }

    private void handlePaymentFailed(PaymentFailedEvent event) {
        log.error("Payment failed for order {}: {}. Starting compensation.", event.orderId(), event.reason());
        orderRepository.findById(event.orderId()).ifPresent(order -> {
            order.markPaymentFailed();
            order.setStatus("FAILED_PAYMENT");
            orderRepository.save(order);
            
            // Compensate inventory
            CompensateInventoryCommand command = new CompensateInventoryCommand(
                    order.getId(),
                    order.getItems().stream().map(this::toEventItem).toList(),
                    Instant.now()
            );
            kafkaTemplate.send("inventory-commands", command.orderId().toString(), command);
            
            OrderFailedEvent failedEvent = new OrderFailedEvent(order.getId(), event.reason(), Instant.now());
            kafkaTemplate.send("order-events", failedEvent.orderId().toString(), failedEvent);
        });
    }

    private OrderItemEvent toEventItem(OrderItem item) {
        return new OrderItemEvent(item.getProductId(), item.getProductName(), item.getQuantity(), item.getUnitPrice());
    }
}
