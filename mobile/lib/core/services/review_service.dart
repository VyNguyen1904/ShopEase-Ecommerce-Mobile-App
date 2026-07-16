import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/review.dart';

class ReviewService {
  final Dio _dio;

  String get _host {
    if (kIsWeb) {
      final host = Uri.base.host;
      return "http://${host.isNotEmpty ? host : '127.0.0.1'}:8000";
    }
    try {
      if (Platform.isAndroid) return 'http://192.168.3.6:8000';
    } catch (_) {}
    return 'http://127.0.0.1:8000';
  }

  String get _baseUrl => '$_host/api/reviews';

  ReviewService({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<Review>> getProductReviews(String productId) async {
    try {
      final response = await _dio.get('$_baseUrl/products/$productId');
      final data = (response.data['data'] as List<dynamic>?) ?? [];
      return data.map((json) => Review.fromJson(json)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Review>> getMyReviews() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get('$_baseUrl/me', options: options);
      final data = (response.data['data'] as List<dynamic>?) ?? [];
      return data.map((json) => Review.fromJson(json)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<Options> _getAuthOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return Options(
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
  }

  Future<Review> createReview({
    required String productId,
    required String orderId,
    required int rating,
    required String title,
    required String body,
    List<String> imageUrls = const [],
  }) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        _baseUrl,
        data: {
          'productId': productId,
          'orderId': orderId,
          'rating': rating,
          'title': title,
          'body': body,
          'imageUrls': imageUrls,
        },
        options: options,
      );
      return Review.fromJson(response.data['data']);
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        final message = data['message'] ?? data['error'] ?? e.toString();
        throw Exception(message);
      }
      throw Exception('Failed to create review: $e');
    }
  }
}
