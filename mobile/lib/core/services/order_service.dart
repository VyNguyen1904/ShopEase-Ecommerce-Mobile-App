import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';

class OrderService {
  final Dio _dio;

  String get _host {
    if (kIsWeb) {
      final host = Uri.base.host;
      return "http://${host.isNotEmpty ? host : '127.0.0.1'}:8000";
    }
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    } catch (_) {}
    return 'http://127.0.0.1:8000';
  }

  String get _orderUrl => '$_host/api/orders';

  OrderService({Dio? dio}) : _dio = dio ?? Dio();

  Future<Options> _getAuthOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return Options(
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
  }

  Future<OrderResponse> createOrder(CreateOrderRequest request) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        _orderUrl,
        data: request.toJson(),
        options: options,
      );
      return OrderResponse.fromJson(response.data['data']);
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        final message = data['message'] ?? data['error'] ?? e.toString();
        throw Exception(message);
      }
      throw Exception('Failed to create order: $e');
    }
  }

  Future<List<OrderResponse>> getOrderHistory() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(_orderUrl, options: options);
      dynamic data =
          response.data['data'] ?? response.data['content'] ?? response.data;
      if (data is Map) {
        data = data['content'] ?? data['data'] ?? [];
      }
      if (data == null) return [];
      return (data as List)
          .map((json) => OrderResponse.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get order history: $e');
    }
  }

  Future<List<OrderResponse>> getSellerOrders() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get('$_orderUrl/seller', options: options);
      dynamic data =
          response.data['data'] ?? response.data['content'] ?? response.data;
      if (data is Map) {
        data = data['content'] ?? data['data'] ?? [];
      }
      if (data == null) return [];
      return (data as List)
          .map((json) => OrderResponse.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get seller orders: $e');
    }
  }

  Future<OrderResponse> getOrderDetail(String id) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get('$_orderUrl/$id', options: options);
      return OrderResponse.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get order detail: $e');
    }
  }

  Future<OrderResponse> cancelOrder(String id) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        '$_orderUrl/$id/cancel',
        options: options,
      );
      return OrderResponse.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  Future<OrderResponse> updatePaymentStatus(String id, bool paid) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        '$_orderUrl/$id/payment-status',
        data: {'paid': paid},
        options: options,
      );
      return OrderResponse.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  Future<OrderResponse> markAsDelivered(String id) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        '$_orderUrl/$id/deliver',
        options: options,
      );
      return OrderResponse.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to mark order as delivered: $e');
    }
  }

  Future<OrderResponse> confirmOrder(String id) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        '$_orderUrl/$id/confirm',
        options: options,
      );
      return OrderResponse.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to confirm order: $e');
    }
  }

  Future<OrderResponse> packOrder(String id) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post('$_orderUrl/$id/pack', options: options);
      return OrderResponse.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to pack order: $e');
    }
  }

  Future<OrderResponse> shipOrder(String id) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post('$_orderUrl/$id/ship', options: options);
      return OrderResponse.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to ship order: $e');
    }
  }
}
