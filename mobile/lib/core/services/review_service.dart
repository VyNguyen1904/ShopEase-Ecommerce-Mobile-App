import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import '../models/review.dart';

class ReviewService {
  final Dio _dio;

  String get _host => kIsWeb
      ? 'http://localhost:8000'
      : (Platform.isAndroid ? 'http://10.0.2.2:8000' : 'http://localhost:8000');

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
}
