import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import '../models/product.dart';

class ProductService {
  final Dio _dio;

  String get _host {
    if (kIsWeb) return 'http://localhost:8000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    } catch (_) {}
    return 'http://localhost:8000';
  }

  String get _baseUrl => '$_host/api/products';

  ProductService({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<Product>> getProducts({int page = 0, int size = 20}) async {
    try {
      final response = await _dio.get('$_baseUrl?page=$page&size=$size');
      
      final data = response.data['data']; 
      if (data == null) return [];

      List<dynamic> content = [];
      if (data is List) {
        content = data;
      } else if (data is Map) {
        content = data['content'] ?? [];
      }
      
      return content.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }
}
