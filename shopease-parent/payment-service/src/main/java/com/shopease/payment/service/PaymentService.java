package com.shopease.payment.service;

import lombok.RequiredArgsConstructor;

import com.shopease.common.domain.PaymentStatus;
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

    @Transactional
    public PaymentResponse simulate(UUID orderId, boolean success) {
        return simulatePaymentResult(orderId, success);
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
    public CheckoutPaymentResponse handleSimulatedWebhook(String orderId, boolean success) {
        String normalizedOrderId = normalizeOrderId(orderId);
        CheckoutPaymentResponse response = demoLedger.compute(normalizedOrderId, (key, current) -> {
            CheckoutPaymentResponse base = current == null ? pendingQrResponse(orderId.trim()) : current;
            String status = success ? "SUCCESS" : "FAILED";
            String message = success ? "QR payment confirmed by simulated webhook."
                    : "QR payment failed by simulated webhook.";
            return base.withStatus(status, message);
        });
        syncPersistentPayment(response, parseOrderId(response.orderId()));
        return response;
    }

    public String qrSvg(String orderId) {
        String label = escapeXml(orderId);
        int cells = 15;
        int cell = 12;
        int quiet = 20;
        int size = quiet * 2 + cells * cell;
        int hash = orderId.hashCode();
        StringBuilder svg = new StringBuilder();
        svg.append("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"").append(size).append("\" height=\"")
                .append(size + 32).append("\" viewBox=\"0 0 ").append(size).append(' ').append(size + 32)
                .append("\">");
        svg.append("<rect width=\"100%\" height=\"100%\" fill=\"#ffffff\"/>");
        appendFinder(svg, quiet, quiet, cell);
        appendFinder(svg, quiet + (cells - 4) * cell, quiet, cell);
        appendFinder(svg, quiet, quiet + (cells - 4) * cell, cell);
        for (int y = 0; y < cells; y++) {
            for (int x = 0; x < cells; x++) {
                if (insideFinder(x, y, cells)) {
                    continue;
                }
                int bit = Math.floorMod(hash + x * 31 + y * 17 + x * y, 7);
                if (bit == 0 || bit == 3 || bit == 5) {
                    svg.append("<rect x=\"").append(quiet + x * cell).append("\" y=\"").append(quiet + y * cell)
                            .append("\" width=\"").append(cell).append("\" height=\"").append(cell)
                            .append("\" fill=\"#111827\"/>");
                }
            }
        }
        svg.append("<text x=\"").append(size / 2).append("\" y=\"").append(size + 20)
                .append("\" text-anchor=\"middle\" font-family=\"Arial, sans-serif\" font-size=\"13\" fill=\"#111827\">")
                .append(label).append("</text></svg>");
        return svg.toString();
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
        return PaymentResponse.from(payments.save(current));
    }

    @Transactional
    public RefundResponse processRefund(UUID transactionId, RefundRequest request) {
        payments.findById(transactionId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Payment not found"));
        return RefundResponse.from(refunds.save(new Refund(UUID.randomUUID(), transactionId, request.amount(), request.reason(), "COMPLETED", Instant.now())));
    }

    private CheckoutPaymentResponse processCheckoutInternal(CheckoutPaymentRequest request) {
        simulateGatewayLatency();
        String method = request.paymentMethod().trim().toUpperCase();
        if (isQrMethod(method)) {
            return pendingQrResponse(request.orderId().trim());
        }

        String cardDigits = digitsOnly(request.cardNumber());
        if (cardDigits.isBlank()) {
            return new CheckoutPaymentResponse(nextTransactionId(), request.orderId().trim(), "FAILED_INVALID_CARD",
                    "Card number is required.", Instant.now(), null);
        }
        if (cardDigits.endsWith("1111")) {
            return new CheckoutPaymentResponse(nextTransactionId(), request.orderId().trim(),
                    "FAILED_INSUFFICIENT_FUNDS", "Declined: Insufficient funds.", Instant.now(), null);
        }
        if (cardDigits.endsWith("2222")) {
            return new CheckoutPaymentResponse(nextTransactionId(), request.orderId().trim(), "FAILED_EXPIRED_CARD",
                    "This card is expired.", Instant.now(), null);
        }
        return new CheckoutPaymentResponse(nextTransactionId(), request.orderId().trim(), "SUCCESS",
                "Payment approved successfully.", Instant.now(), null);
    }

    private CheckoutPaymentResponse pendingQrResponse(String orderId) {
        return new CheckoutPaymentResponse(nextTransactionId(), orderId, "PENDING",
                "QR payment initiated. Waiting for webhook confirmation.", Instant.now(), qrPath(orderId));
    }

    private CheckoutPaymentResponse fromTransaction(PaymentTransaction payment) {
        String status = switch (payment.getStatus()) {
            case PAID -> "SUCCESS";
            case PENDING -> "PENDING";
            default -> "FAILED";
        };
        String transactionId = payment.getGatewayTxnId() == null ? payment.getId().toString() : payment.getGatewayTxnId();
        return new CheckoutPaymentResponse(transactionId, payment.getOrderId().toString(), status,
                "Payment status loaded from transaction ledger.", Instant.now(), null);
    }

    private void syncPersistentPayment(CheckoutPaymentResponse response, UUID orderId) {
        if (orderId == null) return;
        payments.findByOrderId(orderId).ifPresent(payment -> {
            if ("SUCCESS".equals(response.status())) {
                payment.markCompleted();
                payments.save(payment);
            } else if (response.status().startsWith("FAILED")) {
                payment.markFailed();
                payments.save(payment);
            }
        });
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

    private String qrPath(String orderId) {
        return "/api/payments/qr/" + URLEncoder.encode(orderId, StandardCharsets.UTF_8);
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

    private void appendFinder(StringBuilder svg, int x, int y, int cell) {
        int size = cell * 4;
        svg.append("<rect x=\"").append(x).append("\" y=\"").append(y).append("\" width=\"").append(size)
                .append("\" height=\"").append(size).append("\" fill=\"#111827\"/>");
        svg.append("<rect x=\"").append(x + cell).append("\" y=\"").append(y + cell).append("\" width=\"")
                .append(cell * 2).append("\" height=\"").append(cell * 2).append("\" fill=\"#ffffff\"/>");
        svg.append("<rect x=\"").append(x + cell * 3 / 2).append("\" y=\"").append(y + cell * 3 / 2)
                .append("\" width=\"").append(cell).append("\" height=\"").append(cell)
                .append("\" fill=\"#111827\"/>");
    }

    private boolean insideFinder(int x, int y, int cells) {
        return x < 4 && y < 4 || x >= cells - 4 && y < 4 || x < 4 && y >= cells - 4;
    }

    private String escapeXml(String value) {
        return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
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
