package com.shopease.payment.controller;

import com.shopease.payment.config.VNPayConfig;
import com.shopease.payment.service.PaymentService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;

@RestController
@RequestMapping("/api/payments/vnpay")
@RequiredArgsConstructor
public class VNPayController {

    private final PaymentService paymentService;

    @GetMapping("/create")
    public Map<String, String> createPayment(HttpServletRequest request,
                                             @RequestParam("amount") long amount,
                                             @RequestParam("orderId") String orderId) {
        
        long vnp_Amount = amount * 100;
        
        Map<String, String> vnp_Params = new HashMap<>();
        vnp_Params.put("vnp_Version", "2.1.0");
        vnp_Params.put("vnp_Command", "pay");
        vnp_Params.put("vnp_TmnCode", VNPayConfig.vnp_TmnCode);
        vnp_Params.put("vnp_Amount", String.valueOf(vnp_Amount));
        vnp_Params.put("vnp_CurrCode", "VND");
        vnp_Params.put("vnp_TxnRef", orderId + "_" + VNPayConfig.getRandomNumber(4));
        vnp_Params.put("vnp_OrderInfo", "Thanh toan don hang: " + orderId);
        vnp_Params.put("vnp_OrderType", "other");
        vnp_Params.put("vnp_Locale", "vn");
        vnp_Params.put("vnp_ReturnUrl", VNPayConfig.vnp_ReturnUrl);
        vnp_Params.put("vnp_IpAddr", "127.0.0.1");

        Calendar cld = Calendar.getInstance(TimeZone.getTimeZone("Asia/Ho_Chi_Minh"));
        SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
        formatter.setTimeZone(TimeZone.getTimeZone("Asia/Ho_Chi_Minh"));
        String vnp_CreateDate = formatter.format(cld.getTime());
        vnp_Params.put("vnp_CreateDate", vnp_CreateDate);
        
        cld.add(Calendar.MINUTE, 15);
        String vnp_ExpireDate = formatter.format(cld.getTime());
        vnp_Params.put("vnp_ExpireDate", vnp_ExpireDate);
        
        List<String> fieldNames = new ArrayList<>(vnp_Params.keySet());
        Collections.sort(fieldNames);
        StringBuilder hashData = new StringBuilder();
        StringBuilder query = new StringBuilder();
        Iterator<String> itr = fieldNames.iterator();
        while (itr.hasNext()) {
            String fieldName = itr.next();
            String fieldValue = vnp_Params.get(fieldName);
            if ((fieldValue != null) && (fieldValue.length() > 0)) {
                hashData.append(fieldName);
                hashData.append('=');
                hashData.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII));
                query.append(URLEncoder.encode(fieldName, StandardCharsets.US_ASCII));
                query.append('=');
                query.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII));
                if (itr.hasNext()) {
                    query.append('&');
                    hashData.append('&');
                }
            }
        }
        String queryUrl = query.toString();
        String vnp_SecureHash = VNPayConfig.hmacSHA512(VNPayConfig.secretKey, hashData.toString());
        queryUrl += "&vnp_SecureHash=" + vnp_SecureHash;
        String paymentUrl = VNPayConfig.vnp_PayUrl + "?" + queryUrl;
        
        Map<String, String> response = new HashMap<>();
        response.put("url", paymentUrl);
        return response;
    }

    @GetMapping("/callback")
    public void paymentCallback(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Map<String, String> fields = new HashMap<>();
        for (Enumeration<String> params = request.getParameterNames(); params.hasMoreElements();) {
            String fieldName = params.nextElement();
            String fieldValue = request.getParameter(fieldName);
            if (fieldValue != null && fieldValue.length() > 0) {
                fields.put(fieldName, fieldValue);
            }
        }

        String vnp_SecureHash = fields.remove("vnp_SecureHash");
        fields.remove("vnp_SecureHashType");

        String vnp_TxnRef = fields.get("vnp_TxnRef");
        String orderId = vnp_TxnRef != null ? vnp_TxnRef.split("_")[0] : null;
        String vnp_ResponseCode = fields.get("vnp_ResponseCode");

        List<String> fieldNames = new ArrayList<>(fields.keySet());
        Collections.sort(fieldNames);
        StringBuilder hashData = new StringBuilder();
        Iterator<String> itr = fieldNames.iterator();
        while (itr.hasNext()) {
            String fieldName = itr.next();
            String fieldValue = fields.get(fieldName);
            if ((fieldValue != null) && (fieldValue.length() > 0)) {
                hashData.append(fieldName);
                hashData.append('=');
                hashData.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII));
                if (itr.hasNext()) {
                    hashData.append('&');
                }
            }
        }
        String signValue = VNPayConfig.hmacSHA512(VNPayConfig.secretKey, hashData.toString());
        
        response.setContentType("text/html; charset=UTF-8");
        String htmlResponse;
        
        // Auto-close script: tries to deep link back to app after 2s, then attempts to close the window
        String returnUrl = orderId != null ? "shopease:///payment-return/" + orderId : "shopease:///payment-return";
        String autoCloseScript = "<script>setTimeout(function(){window.location.href = '" + returnUrl + "'; setTimeout(function(){window.close();}, 500);}, 2000);</script>";
        
        boolean alreadyPaid = false;
        if (orderId != null) {
            try {
                com.shopease.payment.dto.CheckoutPaymentResponse status = paymentService.getPaymentStatus(orderId);
                if ("SUCCESS".equals(status.status())) {
                    alreadyPaid = true;
                }
            } catch (Exception e) {
                // Ignore
            }
        }

        boolean isValidSignature = signValue.equals(vnp_SecureHash);
        
        if (alreadyPaid || (isValidSignature && "00".equals(vnp_ResponseCode))) {
            // Payment success - update order if not already paid
            if (!alreadyPaid && orderId != null && isValidSignature) {
                try {
                    paymentService.simulate(java.util.UUID.fromString(orderId), true);
                } catch (Exception e) {}
            }
            htmlResponse = "<!DOCTYPE html><html><head><meta charset='UTF-8'><meta name='viewport' content='width=device-width, initial-scale=1.0'><title>Thanh toán thành công</title>"
                + "<style>*{box-sizing:border-box;margin:0;padding:0}"
                + "body{font-family:'Segoe UI',sans-serif;display:flex;justify-content:center;align-items:center;min-height:100vh;background:linear-gradient(135deg,#f0f9ff,#e0f2fe);}"
                + ".box{background:white;padding:30px 20px;border-radius:20px;box-shadow:0 8px 32px rgba(0,0,0,.12);text-align:center;max-width:400px;width:90%;}"
                + ".icon{width:64px;height:64px;background:#10b981;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;margin-bottom:20px;font-size:32px;color:white;}"
                + "h1{color:#10b981;font-size:22px;margin-bottom:10px;}"
                + "p{color:#6b7280;font-size:15px;line-height:1.6;}"
                + ".note{margin-top:20px;font-size:13px;color:#6b7280;font-weight:bold;}"
                + ".btn{display:inline-block;margin-top:20px;padding:12px 24px;background:#10b981;color:white;text-decoration:none;border-radius:8px;font-weight:bold;font-size:15px;}"
                + "</style></head><body>"
                + "<div class='box'>"
                + "<div class='icon'>&#10003;</div>"
                + "<h1>Thanh toán thành công!</h1>"
                + "<p>Đơn hàng của bạn đã được xác nhận.</p>"
                + "<p class='note'>Đang tự động quay lại ứng dụng...</p>"
                + "<a href='" + returnUrl + "' class='btn'>Quay lại Ứng dụng</a>"
                + "</div>"
                + autoCloseScript
                + "</body></html>";
        } else if (isValidSignature && !"00".equals(vnp_ResponseCode)) {
            // Payment failed
            if (orderId != null) {
                try {
                    paymentService.simulate(java.util.UUID.fromString(orderId), false);
                } catch (Exception e) {}
            }
            htmlResponse = "<!DOCTYPE html><html><head><meta charset='UTF-8'><meta name='viewport' content='width=device-width, initial-scale=1.0'><title>Thanh toán thất bại</title>"
                + "<style>*{box-sizing:border-box;margin:0;padding:0}"
                + "body{font-family:'Segoe UI',sans-serif;display:flex;justify-content:center;align-items:center;min-height:100vh;background:linear-gradient(135deg,#fff5f5,#fee2e2);}"
                + ".box{background:white;padding:30px 20px;border-radius:20px;box-shadow:0 8px 32px rgba(0,0,0,.12);text-align:center;max-width:400px;width:90%;}"
                + ".icon{width:64px;height:64px;background:#ef4444;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;margin-bottom:20px;font-size:32px;color:white;}"
                + "h1{color:#ef4444;font-size:22px;margin-bottom:10px;}"
                + "p{color:#6b7280;font-size:15px;line-height:1.6;}"
                + ".note{margin-top:20px;font-size:13px;color:#6b7280;font-weight:bold;}"
                + ".btn{display:inline-block;margin-top:20px;padding:12px 24px;background:#ef4444;color:white;text-decoration:none;border-radius:8px;font-weight:bold;font-size:15px;}"
                + "</style></head><body>"
                + "<div class='box'>"
                + "<div class='icon'>&#10007;</div>"
                + "<h1>Thanh toán thất bại!</h1>"
                + "<p>Giao dịch không thành công hoặc đã bị hủy.</p>"
                + "<p class='note'>Đang tự động quay lại ứng dụng...</p>"
                + "<a href='" + returnUrl + "' class='btn'>Quay lại Ứng dụng</a>"
                + "</div>"
                + autoCloseScript
                + "</body></html>";
        } else {
            htmlResponse = "<!DOCTYPE html><html><head><meta charset='UTF-8'><meta name='viewport' content='width=device-width, initial-scale=1.0'><title>Lỗi xác thực</title>"
                + "<style>*{box-sizing:border-box;margin:0;padding:0}"
                + "body{font-family:'Segoe UI',sans-serif;display:flex;justify-content:center;align-items:center;min-height:100vh;background:#fffbeb;}"
                + ".box{background:white;padding:30px 20px;border-radius:20px;box-shadow:0 8px 32px rgba(0,0,0,.12);text-align:center;max-width:400px;width:90%;}"
                + ".icon{width:64px;height:64px;background:#f59e0b;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;margin-bottom:20px;font-size:32px;color:white;}"
                + "h1{color:#f59e0b;font-size:22px;margin-bottom:10px;}"
                + "p{color:#6b7280;font-size:15px;}"
                + ".note{margin-top:20px;font-size:13px;color:#6b7280;font-weight:bold;}"
                + ".btn{display:inline-block;margin-top:20px;padding:12px 24px;background:#f59e0b;color:white;text-decoration:none;border-radius:8px;font-weight:bold;font-size:15px;}"
                + "</style></head><body>"
                + "<div class='box'><div class='icon'>!</div><h1>Lỗi xác thực!</h1><p>Chữ ký không hợp lệ.</p>"
                + "<p class='note'>Đang tự động quay lại ứng dụng...</p>"
                + "<a href='" + returnUrl + "' class='btn'>Quay lại Ứng dụng</a></div>"
                + autoCloseScript
                + "</body></html>";
        }
        
        response.getWriter().write(htmlResponse);
    }
}
