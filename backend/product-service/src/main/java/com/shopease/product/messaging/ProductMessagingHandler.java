package com.shopease.product.messaging;

import com.shopease.common.event.DomainEvents.*;
import com.shopease.product.model.Product;
import com.shopease.product.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
@Slf4j
@RequiredArgsConstructor
public class ProductMessagingHandler {

    private final ProductRepository productRepository;

    private final com.fasterxml.jackson.databind.ObjectMapper objectMapper;

    @KafkaListener(topics = "inventory-commands", groupId = "product-group")
    @Transactional
    public void handleCommands(String payload, @org.springframework.messaging.handler.annotation.Headers java.util.Map<String, Object> headers) {
        String typeId = "";
        Object typeIdObj = headers.get("__TypeId__");
        if (typeIdObj instanceof byte[]) {
            typeId = new String((byte[]) typeIdObj);
        } else if (typeIdObj != null) {
            typeId = typeIdObj.toString();
        }
        log.info("Received inventory command in product service. TypeId: {}, Payload: {}", typeId, payload);
        try {
            if (typeId.contains("ReserveStockCommand")) {
                ReserveStockCommand c = objectMapper.readValue(payload, ReserveStockCommand.class);
                handleReserveStock(c);
            } else if (typeId.contains("CompensateInventoryCommand")) {
                CompensateInventoryCommand c = objectMapper.readValue(payload, CompensateInventoryCommand.class);
                handleCompensateInventory(c);
            }
        } catch (Exception e) {
            log.error("Failed to process inventory command in product service: {}", e.getMessage(), e);
        }
    }

    private void handleReserveStock(ReserveStockCommand c) {
        log.info("Reserve stock command received, updating product stock for order {}", c.orderId());
        for (OrderItemEvent item : c.items()) {
            productRepository.findById(item.productId()).ifPresent(product -> {
                // Update stock and sold count
                int newStock = Math.max(0, product.getStockQuantity() - item.quantity());
                product.increaseSoldCount(item.quantity());
                product.update(
                    product.getName(), product.getSlug(), product.getDescription(), product.getCategory(),
                    product.getBasePrice(), product.getSalePrice(), newStock, product.getWeightKg(),
                    product.getSellerId(), product.getThumbnailUrl(), product.getImageUrls(), product.getColors(),
                    product.getSizes(), product.getMaterial(), product.getFit(), product.getCareInstructions(),
                    product.getFeatures(), product.getStatus(), product.isFeatured()
                );
                productRepository.save(product);
            });
        }
    }

    private void handleCompensateInventory(CompensateInventoryCommand c) {
        log.info("Compensate inventory command received, restoring product stock for order {}", c.orderId());
        for (OrderItemEvent item : c.items()) {
            productRepository.findById(item.productId()).ifPresent(product -> {
                int newStock = product.getStockQuantity() + item.quantity();
                product.decreaseSoldCount(item.quantity());
                product.update(
                    product.getName(), product.getSlug(), product.getDescription(), product.getCategory(),
                    product.getBasePrice(), product.getSalePrice(), newStock, product.getWeightKg(),
                    product.getSellerId(), product.getThumbnailUrl(), product.getImageUrls(), product.getColors(),
                    product.getSizes(), product.getMaterial(), product.getFit(), product.getCareInstructions(),
                    product.getFeatures(), product.getStatus(), product.isFeatured()
                );
                productRepository.save(product);
            });
        }
    }
}
