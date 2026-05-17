package com.shopease.order.dto;

import com.shopease.order.model.Order;
import com.shopease.order.model.OrderItem;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

public final class OrderDTO {
    private OrderDTO() {
    }

    public record CreateOrderRequest(@NotEmpty List<@Valid OrderItemRequest> items, @NotBlank String shipRecipient,
                                     @NotBlank String shipPhone, @NotBlank String shipStreet,
                                     @NotBlank String shipDistrict, @NotBlank String shipCity,
                                     @Pattern(regexp = "COD|CARD|MOMO|VNPAY", flags = Pattern.Flag.CASE_INSENSITIVE) String paymentMethod,
                                     @Size(max = 1000) String note) {
    }

    public record OrderItemRequest(@NotNull Long productId, @Min(1) int quantity) {
    }

    public record OrderItemResponse(Long id, Long productId, String productName, String productImage,
                                    BigDecimal unitPrice, int quantity, BigDecimal subtotal) {
        public static OrderItemResponse from(OrderItem item) {
            return new OrderItemResponse(item.getId(), item.getProductId(), item.getProductName(), item.getProductImage(),
                    item.getUnitPrice(), item.getQuantity(), item.getSubtotal());
        }
    }

    public record OrderResponse(UUID id, String buyerId, String status, String paymentStatus,
                                List<OrderItemResponse> items, BigDecimal subtotal, BigDecimal shippingFee,
                                BigDecimal discountAmount, BigDecimal totalAmount, String paymentMethod,
                                String shipRecipient, String shipPhone, String shipStreet, String shipDistrict,
                                String shipCity, String note, Instant createdAt) {
        public static OrderResponse from(Order order) {
            return new OrderResponse(order.getId(), order.getBuyerId(), order.getStatus(), order.getPaymentStatus(),
                    order.getItems().stream().map(OrderItemResponse::from).toList(), order.getSubtotal(),
                    order.getShippingFee(), order.getDiscountAmount(), order.getTotalAmount(), order.getPaymentMethod(),
                    order.getShipRecipient(), order.getShipPhone(), order.getShipStreet(), order.getShipDistrict(),
                    order.getShipCity(), order.getNote(), order.getCreatedAt());
        }
    }
}
