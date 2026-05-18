package com.shopease.payment.dto;

import com.shopease.payment.model.PaymentTransaction;
import com.shopease.payment.model.Refund;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

public final class PaymentDtos {
    private PaymentDtos() {
    }

    public record CreatePaymentRequest(@NotNull UUID orderId, @NotBlank String buyerId,
                                       @NotNull @DecimalMin("0.0") BigDecimal amount, @NotBlank String method) {
    }

    public record CheckoutPaymentRequest(@NotBlank String orderId,
                                         @NotNull @DecimalMin("0.0") BigDecimal amount,
                                         String currency,
                                         String cardNumber,
                                         String cardHolder,
                                         String expiryDate,
                                         String cvv,
                                         @NotBlank String paymentMethod) {
    }

    public record CheckoutPaymentResponse(String transactionId, String orderId, String status, String message,
                                          Instant timestamp, String qrPayload) {
        public CheckoutPaymentResponse withMessage(String nextMessage) {
            return new CheckoutPaymentResponse(transactionId, orderId, status, nextMessage, timestamp, qrPayload);
        }

        public CheckoutPaymentResponse withStatus(String nextStatus, String nextMessage) {
            return new CheckoutPaymentResponse(transactionId, orderId, nextStatus, nextMessage, Instant.now(), qrPayload);
        }
    }

    public record RefundRequest(@NotNull @DecimalMin("0.0") BigDecimal amount, String reason) {
    }

    public record PaymentResponse(UUID id, UUID orderId, String buyerId, BigDecimal amount, String currency,
                                  String method, String status, String gatewayTxnId, Instant paidAt, Instant createdAt) {
        public static PaymentResponse from(PaymentTransaction payment) {
            return new PaymentResponse(payment.getId(), payment.getOrderId(), payment.getBuyerId(), payment.getAmount(),
                    payment.getCurrency(), payment.getMethod(), payment.getStatus(), payment.getGatewayTxnId(),
                    payment.getPaidAt(), payment.getCreatedAt());
        }
    }

    public record RefundResponse(UUID id, UUID transactionId, BigDecimal amount, String reason, String status,
                                 Instant refundedAt) {
        public static RefundResponse from(Refund refund) {
            return new RefundResponse(refund.getId(), refund.getTransactionId(), refund.getAmount(), refund.getReason(),
                    refund.getStatus(), refund.getRefundedAt());
        }
    }
}
