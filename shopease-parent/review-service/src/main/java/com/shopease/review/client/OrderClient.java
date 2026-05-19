package com.shopease.review.client;

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

import java.util.UUID;

@Component
public class OrderClient {
    private static final ParameterizedTypeReference<ApiResponse<ReviewEligibilityResponse>> ELIGIBILITY_RESPONSE =
            new ParameterizedTypeReference<>() {
            };

    private final RestClient orderClient;

    public OrderClient(RestClient.Builder restClientBuilder,
                       @Value("${clients.order-service.url:http://localhost:8085}") String orderServiceUrl) {
        this.orderClient = restClientBuilder.baseUrl(orderServiceUrl).build();
    }

    public void requireReviewEligible(String buyerId, UUID orderId, Long productId) {
        try {
            ApiResponse<ReviewEligibilityResponse> response = orderClient.get()
                    .uri(uriBuilder -> uriBuilder.path("/api/orders/{id}/review-eligibility")
                            .queryParam("productId", productId)
                            .build(orderId))
                    .header("X-User-Id", buyerId)
                    .retrieve()
                    .body(ELIGIBILITY_RESPONSE);
            if (response == null || !response.success() || response.data() == null) {
                throw new ResponseStatusException(HttpStatus.BAD_GATEWAY,
                        "Order service returned an empty eligibility response");
            }
            ReviewEligibilityResponse eligibility = response.data();
            if (!eligibility.eligible()) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, eligibility.reason());
            }
        } catch (RestClientResponseException ex) {
            if (ex.getStatusCode().value() == 404) {
                throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Order not found", ex);
            }
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "Order service rejected review eligibility", ex);
        } catch (ResourceAccessException ex) {
            throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE, "Order service is unavailable", ex);
        }
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    private record ReviewEligibilityResponse(UUID orderId, String buyerId, Long productId, boolean eligible,
                                             String reason) {
    }
}
