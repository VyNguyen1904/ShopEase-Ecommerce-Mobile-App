import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import '../models/category.dart';

class CategoryService {
  final Dio _dio;

  String get _host {
    if (kIsWeb) {
      final host = Uri.base.host;
      return "http://${host.isNotEmpty ? host : '127.0.0.1'}:8000";
    }
    try {
      if (Platform.isAndroid) return 'http://172.20.10.5:8000';
    } catch (_) {}
    return 'http://127.0.0.1:8000';
  }

  String get _baseUrl => '$_host/api/categories';

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
