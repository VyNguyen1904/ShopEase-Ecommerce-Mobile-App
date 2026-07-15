package com.shopease.inventory.messaging;

import com.shopease.common.event.DomainEvents.*;
import com.shopease.inventory.dto.ReservationRequest;
import com.shopease.inventory.service.InventoryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

import java.time.Instant;

@Component
@Slf4j
@RequiredArgsConstructor
public class InventoryMessagingHandler {

    private final InventoryService inventoryService;
    private final KafkaTemplate<String, Object> kafkaTemplate;

    private final com.fasterxml.jackson.databind.ObjectMapper objectMapper;

    @KafkaListener(topics = "inventory-commands", groupId = "inventory-group")
    public void handleCommands(String payload, @org.springframework.messaging.handler.annotation.Headers java.util.Map<String, Object> headers) {
        String typeId = "";
        Object typeIdObj = headers.get("__TypeId__");
        if (typeIdObj instanceof byte[]) {
            typeId = new String((byte[]) typeIdObj);
        } else if (typeIdObj != null) {
            typeId = typeIdObj.toString();
        }
        log.info("Received inventory command. TypeId: {}, Payload: {}", typeId, payload);
        try {
            if (typeId.contains("ReserveStockCommand")) {
                ReserveStockCommand command = objectMapper.readValue(payload, ReserveStockCommand.class);
                handleReserveStock(command);
            } else if (typeId.contains("CompensateInventoryCommand")) {
                CompensateInventoryCommand command = objectMapper.readValue(payload, CompensateInventoryCommand.class);
                handleCompensateInventory(command);
            }
        } catch (Exception e) {
            log.error("Failed to process inventory command: {}", e.getMessage(), e);
        }
    }

    private void handleReserveStock(ReserveStockCommand command) {
        log.info("Received reserve stock command for order {}", command.orderId());
        try {
            for (OrderItemEvent item : command.items()) {
                inventoryService.reserve(new ReservationRequest(item.productId(), item.quantity()));
            }
            StockReservedEvent event = new StockReservedEvent(command.orderId(), Instant.now());
            kafkaTemplate.send("inventory-events", event.orderId().toString(), event);
        } catch (Exception ex) {
            log.error("Stock reservation failed for order {}: {}", command.orderId(), ex.getMessage());
            StockReservationFailedEvent event = new StockReservationFailedEvent(command.orderId(), ex.getMessage(), Instant.now());
            kafkaTemplate.send("inventory-events", event.orderId().toString(), event);
        }
    }

    private void handleCompensateInventory(CompensateInventoryCommand command) {
        log.info("Received compensate inventory command for order {}", command.orderId());
        try {
            for (OrderItemEvent item : command.items()) {
                inventoryService.release(new ReservationRequest(item.productId(), item.quantity()));
            }
            log.info("Inventory compensated for order {}", command.orderId());
        } catch (Exception ex) {
            log.error("Inventory compensation failed for order {}: {}", command.orderId(), ex.getMessage());
        }
    }
}
