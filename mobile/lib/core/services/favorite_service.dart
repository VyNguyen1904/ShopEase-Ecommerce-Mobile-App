import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class FavoriteService {
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

  String get _baseUrl => '$_host/api/favorites';

  FavoriteService({Dio? dio}) : _dio = dio ?? Dio();

  Future<Options> _getAuthOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return Options(
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
  }

  Future<List<Product>> getFavorites() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(_baseUrl, options: options);
      final dynamic data = response.data['data'];
      if (data == null) return [];
      
      final List<dynamic> content = data is Map ? (data['content'] ?? []) : data;
      return content.map((json) {
        // Backend could return product directly or { "product": { ... } }
        if (json.containsKey('product')) {
          return Product.fromJson(json['product']);
        }
        return Product.fromJson(json);
      }).toList();
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return [];
      }
      throw Exception('Failed to get favorites: $e');
    }
  }

  Future<void> addFavorite(String productId) async {
    try {
      final options = await _getAuthOptions();
      await _dio.post('$_baseUrl/$productId', options: options);
    } catch (e) {
      throw Exception('Failed to add favorite: $e');
    }
  }

  Future<void> removeFavorite(String productId) async {
    try {
      final options = await _getAuthOptions();
      await _dio.delete('$_baseUrl/$productId', options: options);
    } catch (e) {
      throw Exception('Failed to remove favorite: $e');
    }
  }
}
