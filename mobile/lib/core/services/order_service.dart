import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import '../models/order_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  final Dio _dio;

  String get _host {
    if (kIsWeb) return 'http://localhost:8000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    } catch (_) {}
    return 'http://localhost:8000';
  }

  String get _orderUrl => '$_host/api/orders';

  OrderService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'].toString();
      }
      return e.response!.statusMessage ?? 'Lỗi máy chủ (${e.response!.statusCode})';
    }
    return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng.';
  }

  Future<OrderModel> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await _dio.post(_orderUrl, data: orderData);
      return OrderModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<OrderModel>> getOrderHistory() async {
    try {
      final response = await _dio.get(_orderUrl);
      final List data = response.data['data'] ?? [];
      return data.map((json) => OrderModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<OrderModel> getOrderDetail(String orderId) async {
    try {
      final response = await _dio.get('$_orderUrl/$orderId');
      return OrderModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }
}
