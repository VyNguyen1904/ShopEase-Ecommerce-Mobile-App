import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/review.dart';

class ReviewService {
  final Dio _dio;

  String get _host {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000';
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
      // Return mock data for UI building purposes if endpoint doesn't exist
      await Future.delayed(const Duration(seconds: 1));
      return [
        Review(
          id: 'mock_1',
          productId: 'prod_1',
          orderId: 'order_1',
          buyerId: 'me',
          rating: 5,
          title: 'Sản phẩm tuyệt vời',
          body: 'Chất lượng vải tốt, form đẹp đúng như hình mẫu. Giao hàng nhanh!',
          imageUrls: [],
          status: 'ACTIVE',
          helpfulCount: 2,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          productName: 'Áo Thun Nam Cotton',
          productImage: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400',
        ),
        Review(
          id: 'mock_2',
          productId: 'prod_2',
          orderId: 'order_2',
          buyerId: 'me',
          rating: 4,
          title: 'Hơi rộng một chút',
          body: 'Size L có vẻ hơi to so với bình thường, nhưng chất liệu ổn.',
          imageUrls: [],
          status: 'ACTIVE',
          helpfulCount: 0,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          productName: 'Quần Jean Nam Ống Rộng',
          productImage: 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=400',
        ),
      ];
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
