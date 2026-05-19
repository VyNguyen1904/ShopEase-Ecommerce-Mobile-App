package com.shopease.order.client;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.shopease.common.dto.ApiResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientResponseException;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Component
public class PaymentClient {
    private static final ParameterizedTypeReference<ApiResponse<PaymentResponse>> PAYMENT_RESPONSE =
            new ParameterizedTypeReference<>() {
            };

    private final RestClient paymentClient;

    public PaymentClient(RestClient.Builder restClientBuilder,
                         @Value("${clients.payment-service.url:http://localhost:8086}") String paymentServiceUrl) {
        this.paymentClient = restClientBuilder.baseUrl(paymentServiceUrl).build();
    }

    public PaymentResponse create(UUID orderId, String buyerId, BigDecimal amount, String method) {
        try {
            ApiResponse<PaymentResponse> response = paymentClient.post()
                    .uri("/api/payments")
                    .body(new CreatePaymentRequest(orderId, buyerId, amount, method))
                    .retrieve()
                    .body(PAYMENT_RESPONSE);
            if (response == null || !response.success() || response.data() == null) {
                throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "Payment service returned an empty response");
            }
            return response.data();
        } catch (RestClientResponseException ex) {
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "Payment service rejected payment creation", ex);
        } catch (ResourceAccessException ex) {
            throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE, "Payment service is unavailable", ex);
        }
    }

    private record CreatePaymentRequest(UUID orderId, String buyerId, BigDecimal amount, String method) {
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record PaymentResponse(UUID id, UUID orderId, String buyerId, BigDecimal amount, String currency,
                                  String method, String status, String gatewayTxnId, Instant paidAt,
                                  Instant createdAt) {
    }
}
