import 'package:dio/dio.dart';
import '../models/category.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class CategoryService {
  final Dio _dio;
  String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8000/api/categories';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api/categories';
    return 'http://localhost:8000/api/categories';
  }

  CategoryService({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get(_baseUrl);
      final data = response.data['data'] as List;
      return data.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải danh mục: $e');
    }
  }
}
