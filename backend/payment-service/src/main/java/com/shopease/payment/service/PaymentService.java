package com.shopease.payment.service;

import lombok.RequiredArgsConstructor;

import com.shopease.common.domain.PaymentStatus;
import com.shopease.common.event.DomainEvents.PaymentFailedEvent;
import com.shopease.common.event.DomainEvents.PaymentProcessedEvent;
import com.shopease.payment.dto.CheckoutPaymentRequest;
import com.shopease.payment.dto.CheckoutPaymentResponse;
import com.shopease.payment.dto.CreatePaymentRequest;
import com.shopease.payment.dto.PaymentResponse;
import com.shopease.payment.dto.RefundRequest;
import com.shopease.payment.dto.RefundResponse;
import com.shopease.payment.model.PaymentTransaction;
import com.shopease.payment.model.Refund;
import com.shopease.payment.repository.PaymentRepository;
import com.shopease.payment.repository.RefundRepository;
import org.springframework.http.HttpStatus;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;
import java.util.concurrent.atomic.AtomicBoolean;

@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
public class PaymentService {
    private static final long CHECKOUT_LATENCY_MILLIS = 1500;
    private static final String IDEMPOTENCY_REPLAY_SUFFIX = " [REPLAYED FROM IDEMPOTENCY CACHE]";

    private final PaymentRepository payments;
    private final RefundRepository refunds;
    private final KafkaTemplate<String, Object> kafkaTemplate;

    private final ConcurrentMap<String, IdempotencyRecord> idempotencyRegistry = new ConcurrentHashMap<>();
    private final ConcurrentMap<String, CheckoutPaymentResponse> demoLedger = new ConcurrentHashMap<>();


    @Transactional
    public PaymentResponse createPaymentTransaction(CreatePaymentRequest request) {
        return PaymentResponse.from(payments.save(new PaymentTransaction(UUID.randomUUID(), request.orderId(), request.buyerId(),
                request.amount(), "VND", request.method(), PaymentStatus.PENDING, null, null, Instant.now())));
    }

    @Transactional
    public PaymentResponse create(CreatePaymentRequest request) {
        return createPaymentTransaction(request);
    }



    public List<PaymentResponse> listPaymentTransactions() {
        return payments.findAll().stream().map(PaymentResponse::from).toList();
    }

    public PaymentResponse getPaymentByOrder(UUID orderId) {
        return PaymentResponse.from(payments.findByOrderId(orderId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Payment not found")));
    }

    @Transactional
    public CheckoutPaymentResponse processCheckout(CheckoutPaymentRequest request, String idempotencyKey) {
        String normalizedIdempotencyKey = requireIdempotencyKey(idempotencyKey);
        AtomicBoolean claimed = new AtomicBoolean(false);
        IdempotencyRecord record = idempotencyRegistry.compute(normalizedIdempotencyKey, (key, current) -> {
            if (current == null) {
                claimed.set(true);
                return IdempotencyRecord.processing();
            }
            return current;
        });

        if (!claimed.get()) {
            if (record.isCompleted()) {
                return record.response().withMessage(replayMessage(record.response().message()));
            }
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Payment is already processing for this Idempotency-Key");
        }

        try {
            CheckoutPaymentResponse response = processCheckoutInternal(request);
            demoLedger.put(normalizeOrderId(response.orderId()), response);
            record.complete(response);
            syncPersistentPayment(response, parseOrderId(response.orderId()));
            return response;
        } catch (RuntimeException ex) {
            idempotencyRegistry.remove(normalizedIdempotencyKey, record);
            throw ex;
        }
    }

    public CheckoutPaymentResponse getPaymentStatus(String orderId) {
        String normalizedOrderId = normalizeOrderId(orderId);
        CheckoutPaymentResponse response = demoLedger.get(normalizedOrderId);
        if (response != null) {
            return response;
        }

        try {
            UUID uuid = UUID.fromString(normalizedOrderId);
            return payments.findByOrderId(uuid)
                    .map(this::fromTransaction)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Payment status not found"));
        } catch (IllegalArgumentException ex) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Payment status not found");
        }
    }

    @Transactional
    public PaymentResponse simulate(UUID orderId, boolean success) {
        return simulatePaymentResult(orderId, success);
    }

    @Transactional
    public PaymentResponse simulatePaymentResult(UUID orderId, boolean success) {
        PaymentTransaction current = payments.findByOrderId(orderId).orElseGet(() -> payments.save(
                new PaymentTransaction(UUID.randomUUID(), orderId, "demo-buyer", BigDecimal.ZERO, "VND", "COD",
                        PaymentStatus.PENDING, null, null, Instant.now())));
        if (success) {
            current.markCompleted();
        } else {
            current.markFailed();
        }
        PaymentTransaction saved = payments.save(current);
        
        if (success) {
            kafkaTemplate.send("payment-events", orderId.toString(),
                    new PaymentProcessedEvent(orderId, saved.getId(), Instant.now()));
        } else {
            kafkaTemplate.send("payment-events", orderId.toString(),
                    new PaymentFailedEvent(orderId, "Payment failed via simulation", Instant.now()));
        }
        
        return PaymentResponse.from(saved);
    }
    @Transactional
    public RefundResponse processRefund(UUID transactionId, RefundRequest request) {
        payments.findById(transactionId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Payment not found"));
        return RefundResponse.from(refunds.save(new Refund(UUID.randomUUID(), transactionId, request.amount(), request.reason(), "COMPLETED", Instant.now())));
    }

    private CheckoutPaymentResponse processCheckoutInternal(CheckoutPaymentRequest request) {
        simulateGatewayLatency();
        String method = request.paymentMethod().trim().toUpperCase();
        
        if ("VNPAY".equals(method)) {
            return pendingVnPayResponse(request);
        }
        
        if (isQrMethod(method)) {
            return new CheckoutPaymentResponse(nextTransactionId(), request.orderId().trim(), "PENDING",
                    "QR payment initiated.", Instant.now());
        }

        String cardDigits = digitsOnly(request.cardNumber());
        if (cardDigits.isBlank()) {
            return new CheckoutPaymentResponse(nextTransactionId(), request.orderId().trim(), "FAILED_INVALID_CARD",
                    "Card number is required.", Instant.now());
        }
        if (cardDigits.endsWith("1111")) {
            return new CheckoutPaymentResponse(nextTransactionId(), request.orderId().trim(),
                    "FAILED_INSUFFICIENT_FUNDS", "Declined: Insufficient funds.", Instant.now());
        }
        if (cardDigits.endsWith("2222")) {
            return new CheckoutPaymentResponse(nextTransactionId(), request.orderId().trim(), "FAILED_EXPIRED_CARD",
                    "This card is expired.", Instant.now());
        }
        return new CheckoutPaymentResponse(nextTransactionId(), request.orderId().trim(), "SUCCESS",
                "Payment approved successfully.", Instant.now());
    }



    private CheckoutPaymentResponse pendingVnPayResponse(CheckoutPaymentRequest request) {
        String vnp_Version = com.shopease.payment.config.VNPayConfig.vnp_Version;
        String vnp_Command = com.shopease.payment.config.VNPayConfig.vnp_Command;
        String vnp_OrderInfo = "Thanh toan don hang " + request.orderId();
        String orderType = "other";
        String vnp_TxnRef = com.shopease.payment.config.VNPayConfig.vnp_TmnCode + String.valueOf(System.currentTimeMillis());
        String vnp_IpAddr = "127.0.0.1";
        String vnp_TmnCode = com.shopease.payment.config.VNPayConfig.vnp_TmnCode;

        long amount = request.amount().longValue() * 100;
        java.util.Map<String, String> vnp_Params = new java.util.HashMap<>();
        vnp_Params.put("vnp_Version", vnp_Version);
        vnp_Params.put("vnp_Command", vnp_Command);
        vnp_Params.put("vnp_TmnCode", vnp_TmnCode);
        vnp_Params.put("vnp_Amount", String.valueOf(amount));
        vnp_Params.put("vnp_CurrCode", "VND");
        
        vnp_Params.put("vnp_TxnRef", vnp_TxnRef);
        vnp_Params.put("vnp_OrderInfo", vnp_OrderInfo);
        vnp_Params.put("vnp_OrderType", orderType);
        
        vnp_Params.put("vnp_Locale", "vn");
        String returnUrl = getDynamicReturnUrl("/api/payments/vnpay/callback");
        vnp_Params.put("vnp_ReturnUrl", returnUrl + "?orderId=" + request.orderId());
        vnp_Params.put("vnp_IpAddr", vnp_IpAddr);

        java.util.Calendar cld = java.util.Calendar.getInstance(java.util.TimeZone.getTimeZone("Etc/GMT-7"));
        java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat("yyyyMMddHHmmss");
        formatter.setTimeZone(java.util.TimeZone.getTimeZone("Etc/GMT-7"));
        String vnp_CreateDate = formatter.format(cld.getTime());
        vnp_Params.put("vnp_CreateDate", vnp_CreateDate);
        
        cld.add(java.util.Calendar.MINUTE, 15);
        String vnp_ExpireDate = formatter.format(cld.getTime());
        vnp_Params.put("vnp_ExpireDate", vnp_ExpireDate);

        java.util.List<String> fieldNames = new java.util.ArrayList<>(vnp_Params.keySet());
        java.util.Collections.sort(fieldNames);
        StringBuilder hashData = new StringBuilder();
        StringBuilder query = new StringBuilder();
        java.util.Iterator<String> itr = fieldNames.iterator();
        while (itr.hasNext()) {
            String fieldName = (String) itr.next();
            String fieldValue = (String) vnp_Params.get(fieldName);
            if ((fieldValue != null) && (fieldValue.length() > 0)) {
                String encodedFieldName = URLEncoder.encode(fieldName, StandardCharsets.UTF_8).replace("+", "%20");
                String encodedFieldValue = URLEncoder.encode(fieldValue, StandardCharsets.UTF_8).replace("+", "%20");
                
                hashData.append(encodedFieldName);
                hashData.append('=');
                hashData.append(encodedFieldValue);
                
                query.append(encodedFieldName);
                query.append('=');
                query.append(encodedFieldValue);
                
                if (itr.hasNext()) {
                    query.append('&');
                    hashData.append('&');
                }
            }
        }
        String queryUrl = query.toString();
        String vnp_SecureHash = com.shopease.payment.config.VNPayConfig.hmacSHA512(com.shopease.payment.config.VNPayConfig.secretKey, hashData.toString());
        queryUrl += "&vnp_SecureHash=" + vnp_SecureHash;
        String paymentUrl = com.shopease.payment.config.VNPayConfig.vnp_PayUrl + "?" + queryUrl;

        return new CheckoutPaymentResponse(nextTransactionId(), request.orderId().trim(), "PENDING",
                "VNPAY payment initiated.", Instant.now(), paymentUrl);
    }

    private CheckoutPaymentResponse fromTransaction(PaymentTransaction payment) {
        String status = switch (payment.getStatus()) {
            case PAID -> "SUCCESS";
            case PENDING -> "PENDING";
            default -> "FAILED";
        };
        String transactionId = payment.getGatewayTxnId() == null ? payment.getId().toString() : payment.getGatewayTxnId();
        return new CheckoutPaymentResponse(transactionId, payment.getOrderId().toString(), status,
                "Payment status loaded from transaction ledger.", Instant.now());
    }

    private void syncPersistentPayment(CheckoutPaymentResponse response, UUID orderId) {
        if (orderId == null) return;
        PaymentTransaction payment = payments.findByOrderId(orderId).orElseGet(() -> payments.save(
                new PaymentTransaction(UUID.randomUUID(), orderId, "demo-buyer", BigDecimal.ZERO, "VND", "VNPAY",
                        PaymentStatus.PENDING, null, null, Instant.now())));

        if ("SUCCESS".equals(response.status())) {
            payment.markCompleted();
            payments.save(payment);
            kafkaTemplate.send("payment-events", orderId.toString(),
                    new PaymentProcessedEvent(orderId, payment.getId(), Instant.now()));
        } else if (response.status().startsWith("FAILED")) {
            payment.markFailed();
            payments.save(payment);
            kafkaTemplate.send("payment-events", orderId.toString(),
                    new PaymentFailedEvent(orderId, response.message(), Instant.now()));
        }
    }

    private UUID parseOrderId(String orderId) {
        try {
            return UUID.fromString(orderId);
        } catch (IllegalArgumentException ex) {
            return null;
        }
    }

    private void simulateGatewayLatency() {
        try {
            Thread.sleep(CHECKOUT_LATENCY_MILLIS);
        } catch (InterruptedException ex) {
            Thread.currentThread().interrupt();
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Payment simulation interrupted", ex);
        }
    }

    private String requireIdempotencyKey(String idempotencyKey) {
        if (idempotencyKey == null || idempotencyKey.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Idempotency-Key header is required");
        }
        return idempotencyKey.trim();
    }

    private String normalizeOrderId(String orderId) {
        if (orderId == null || orderId.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "orderId is required");
        }
        return orderId.trim();
    }



    private String replayMessage(String message) {
        return message.endsWith(IDEMPOTENCY_REPLAY_SUFFIX) ? message : message + IDEMPOTENCY_REPLAY_SUFFIX;
    }

    private boolean isQrMethod(String method) {
        return method.equals("QR_CODE") || method.equals("VNPAY") || method.equals("BANK_TRANSFER")
                || method.equals("PIX");
    }

    private String digitsOnly(String value) {
        return value == null ? "" : value.replaceAll("\\D", "");
    }

    private String nextTransactionId() {
        return "TXN-" + UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();
    }

    private String getDynamicReturnUrl(String path) {
        try {
            org.springframework.web.context.request.ServletRequestAttributes attrs = 
                (org.springframework.web.context.request.ServletRequestAttributes) org.springframework.web.context.request.RequestContextHolder.getRequestAttributes();
            if (attrs != null) {
                jakarta.servlet.http.HttpServletRequest req = attrs.getRequest();
                String scheme = req.getHeader("X-Forwarded-Proto");
                if (scheme == null) scheme = req.getScheme();
                
                String host = req.getHeader("X-Forwarded-Host");
                if (host == null) {
                    host = req.getServerName() + ":" + req.getServerPort();
                }
                return scheme + "://" + host + path;
            }
        } catch (Exception e) {
            log.warn("Could not determine dynamic return URL, using default.");
        }
        return com.shopease.payment.config.VNPayConfig.vnp_ReturnUrl;
    }

    private enum IdempotencyState {
        PROCESSING, COMPLETED
    }

    private static final class IdempotencyRecord {
        private volatile IdempotencyState state;
        private volatile CheckoutPaymentResponse response;

        private IdempotencyRecord(IdempotencyState state) {
            this.state = state;
        }

        static IdempotencyRecord processing() {
            return new IdempotencyRecord(IdempotencyState.PROCESSING);
        }

        boolean isCompleted() {
            return state == IdempotencyState.COMPLETED && response != null;
        }

        CheckoutPaymentResponse response() {
            return response;
        }

        void complete(CheckoutPaymentResponse nextResponse) {
            this.response = nextResponse;
            this.state = IdempotencyState.COMPLETED;
        }
    }
}
