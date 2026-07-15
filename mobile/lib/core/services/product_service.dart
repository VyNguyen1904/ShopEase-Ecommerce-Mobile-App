import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/category_model.dart';

class ProductService {
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

  String get _productUrl => '$_host/api/products';
  String get _categoryUrl => '$_host/api/categories';

  ProductService({Dio? dio}) : _dio = dio ?? Dio();

  Future<Options> _getAuthOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return Options(
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
  }

  // --- Categories ---

  Future<List<CategoryModel>> getCategories() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(_categoryUrl, options: options);
      final dynamic data = response.data['data'];
      if (data == null) return [];
      
      final List<dynamic> content = data is Map ? (data['content'] ?? []) : data;
      return content.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  Future<CategoryModel> createCategory(CategoryModel category) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        _categoryUrl,
        data: category.toJson(),
        options: options,
      );
      return CategoryModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  // --- Products ---

  Future<List<Product>> getProducts({int page = 0, int size = 20, String sortBy = 'createdAt', String sortDir = 'desc'}) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get('$_productUrl?page=$page&size=$size&sortBy=$sortBy&sortDir=$sortDir', options: options);
      final dynamic data = response.data['data'];
      if (data == null) return [];
      
      final List<dynamic> content = data is Map ? (data['content'] ?? []) : data;
      return content.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get products: $e');
    }
  }

  Future<List<Product>> searchProducts(String query, {int page = 0, int size = 20, String sortBy = 'createdAt', String sortDir = 'desc'}) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get('$_productUrl/search?query=$query&page=$page&size=$size&sortBy=$sortBy&sortDir=$sortDir', options: options);
      final dynamic data = response.data['data'];
      if (data == null) return [];
      
      final List<dynamic> content = data is Map ? (data['content'] ?? []) : data;
      return content.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  Future<List<String>> getSuggestions(String query) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get('$_productUrl/suggestions?query=$query', options: options);
      final dynamic data = response.data['data'];
      if (data == null) return [];
      return (data as List).map((e) => e.toString()).toList();
    } catch (e) {
      throw Exception('Failed to get suggestions: $e');
    }
  }

  Future<Product> getProductById(String id) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get('$_productUrl/$id', options: options);
      return Product.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get product details: $e');
    }
  }

  Future<Product> createProduct(Product product) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        _productUrl,
        data: product.toJson(),
        options: options,
      );
      return Product.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  Future<Product> updateProduct(String id, Product product) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.put(
        '$_productUrl/$id',
        data: product.toJson(),
        options: options,
      );
      return Product.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      final options = await _getAuthOptions();
      await _dio.delete('$_productUrl/$id', options: options);
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  Future<List<Product>> getProductsBySeller(String sellerId, {int page = 0, int size = 20}) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '$_productUrl/seller/$sellerId?page=$page&size=$size',
        options: options,
      );
      final dynamic data = response.data['data'];
      if (data == null) return [];
      
      final List<dynamic> content = data is Map ? (data['content'] ?? []) : data;
      return content.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get seller products: $e');
    }
  }
}
