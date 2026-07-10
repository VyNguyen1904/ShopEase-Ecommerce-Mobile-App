package com.shopease.payment.messaging;

import com.shopease.common.event.DomainEvents.PaymentFailedEvent;
import com.shopease.common.event.DomainEvents.PaymentProcessedEvent;
import com.shopease.common.event.DomainEvents.ProcessPaymentCommand;
import com.shopease.payment.dto.CreatePaymentRequest;
import com.shopease.payment.dto.PaymentResponse;
import com.shopease.payment.service.PaymentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

import java.time.Instant;

@Component
@Slf4j
@RequiredArgsConstructor
public class PaymentMessagingHandler {

    private final PaymentService paymentService;
    private final KafkaTemplate<String, Object> kafkaTemplate;

    @KafkaListener(topics = "payment-commands", groupId = "payment-group")
    public void handleCommands(Object command) {
        if (command instanceof ProcessPaymentCommand c) {
            handleProcessPayment(c);
        }
    }

    private void handleProcessPayment(ProcessPaymentCommand command) {
        log.info("Received process payment command for order {}", command.orderId());
        try {
            // For Saga, we first create the payment record in PENDING status
            PaymentResponse response = paymentService.create(new CreatePaymentRequest(
                    command.orderId(),
                    command.buyerId(),
                    command.amount(),
                    command.paymentMethod()));

            // In a real system, we'd wait for a webhook or external gateway.
            // For COD, we approve immediately. For FAIL, we fail immediately.
            // For VNPAY and others, we leave it in PENDING state.
            String method = command.paymentMethod();
            if ("COD".equalsIgnoreCase(method)) {
                paymentService.simulate(command.orderId(), true);
            } else if ("FAIL".equalsIgnoreCase(method)) {
                paymentService.simulate(command.orderId(), false);
            } else {
                log.info("Payment method {} requires external confirmation. Left in PENDING state.", method);
            }
        } catch (Exception ex) {
            log.error("Payment processing failed for order {}: {}", command.orderId(), ex.getMessage());
            PaymentFailedEvent event = new PaymentFailedEvent(
                    command.orderId(),
                    ex.getMessage(),
                    Instant.now());
            kafkaTemplate.send("payment-events", event.orderId().toString(), event);
        }
    }
}
