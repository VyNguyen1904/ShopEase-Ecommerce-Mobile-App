import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/payment_model.dart';
import 'package:uuid/uuid.dart';

class PaymentService {
  final Dio _dio;

  String get _host {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    } catch (_) {}
    return 'http://127.0.0.1:8000';
  }

  String get _baseUrl => '$_host/api/payments';

  PaymentService({Dio? dio}) : _dio = dio ?? Dio();

  Future<Options> _getAuthOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return Options(
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
  }

  Future<CheckoutPaymentResponse> processCheckout(
    CheckoutPaymentRequest request,
  ) async {
    try {
      final options = await _getAuthOptions();
      // Add idempotency key to prevent duplicate payments
      options.headers?['Idempotency-Key'] = const Uuid().v4();
      
      final response = await _dio.post(
        '$_baseUrl/checkout',
        options: options,
        data: request.toJson(),
      );
      
      return CheckoutPaymentResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to process checkout payment: $e');
    }
  }

  Future<CheckoutPaymentResponse> getPaymentStatus(String orderId) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '$_baseUrl/status/$orderId',
        options: options,
      );
      return CheckoutPaymentResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get payment status: $e');
    }
  }

  Future<String> getPaymentQr(String orderId) async {
    try {
      final options = await _getAuthOptions();
      // Expecting SVG payload (string)
      final response = await _dio.get(
        '$_baseUrl/qr/$orderId',
        options: options,
      );
      return response.data.toString();
    } catch (e) {
      throw Exception('Failed to get payment QR: $e');
    }
  }

  Future<void> simulateWebhook(String orderId, {bool success = true}) async {
    try {
      final options = await _getAuthOptions();
      await _dio.post(
        '$_baseUrl/simulate-webhook',
        options: options,
        queryParameters: {
          'orderId': orderId,
          'success': success,
        },
      );
    } catch (e) {
      throw Exception('Failed to simulate webhook: $e');
    }
  }
}
