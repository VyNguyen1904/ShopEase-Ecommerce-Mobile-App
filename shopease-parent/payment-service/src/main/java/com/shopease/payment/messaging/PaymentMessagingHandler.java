package com.shopease.payment.messaging;

import com.shopease.common.event.DomainEvents.PaymentFailedEvent;
import com.shopease.common.event.DomainEvents.PaymentProcessedEvent;
import com.shopease.common.event.DomainEvents.ProcessPaymentCommand;
import com.shopease.payment.dto.PaymentDtos.CreatePaymentRequest;
import com.shopease.payment.dto.PaymentDtos.PaymentResponse;
import com.shopease.payment.service.PaymentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.util.UUID;

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
                    command.paymentMethod()
            ));

            // In a real system, we'd wait for a webhook or external gateway.
            // For this implementation, if it's "COD", we approve immediately.
            // Otherwise, we'd keep it PENDING. But for the Saga flow demo, 
            // let's approve everything that isn't explicitly failed.
            
            boolean success = !command.paymentMethod().equalsIgnoreCase("FAIL");
            
            if (success) {
                paymentService.simulate(command.orderId(), true);
                PaymentProcessedEvent event = new PaymentProcessedEvent(
                        command.orderId(),
                        response.id(),
                        Instant.now()
                );
                kafkaTemplate.send("payment-events", event.orderId().toString(), event);
            } else {
                paymentService.simulate(command.orderId(), false);
                PaymentFailedEvent event = new PaymentFailedEvent(
                        command.orderId(),
                        "Payment declined by gateway",
                        Instant.now()
                );
                kafkaTemplate.send("payment-events", event.orderId().toString(), event);
            }
        } catch (Exception ex) {
            log.error("Payment processing failed for order {}: {}", command.orderId(), ex.getMessage());
            PaymentFailedEvent event = new PaymentFailedEvent(
                    command.orderId(),
                    ex.getMessage(),
                    Instant.now()
            );
            kafkaTemplate.send("payment-events", event.orderId().toString(), event);
        }
    }
}
