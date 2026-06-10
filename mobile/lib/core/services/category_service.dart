import 'package:dio/dio.dart';
import '../models/category.dart';

class CategoryService {
  final Dio _dio;
  final String _baseUrl = 'http://localhost:8000/api/categories';

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
