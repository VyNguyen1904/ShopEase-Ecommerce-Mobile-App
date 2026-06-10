import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_model.dart';

class CartService {
  final Dio _dio;

  String get _host {
    if (kIsWeb) return 'http://localhost:8000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    } catch (_) {}
    return 'http://localhost:8000';
  }

  String get _baseUrl => '$_host/api/cart';
  String get _productUrl => '$_host/api/products';

  CartService({Dio? dio}) : _dio = dio ?? Dio();

  Future<Options> _getAuthOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return Options(
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
  }

  Future<CartResponse> getCart(String userId) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(_baseUrl, options: options);

      final cartData = response.data['data'];
      if (cartData == null) {
        return CartResponse(
          userId: userId,
          items: [],
          subtotal: 0,
          totalItems: 0,
        );
      }

      final cart = CartResponse.fromJson(cartData);

      // Fetch product details concurrently to reduce latency
      await Future.wait(
        cart.items.map((item) async {
          try {
            final productRes = await _dio.get('$_productUrl/${item.productId}');
            final productData = productRes.data['data'];
            if (productData != null) {
              item.productName = productData['name'];

              // Map the first image if available
              if (productData['imageUrls'] != null &&
                  (productData['imageUrls'] as List).isNotEmpty) {
                item.productImageUrl = productData['imageUrls'][0];
              } else if (productData['images'] != null &&
                  (productData['images'] as List).isNotEmpty) {
                item.productImageUrl = productData['images'][0];
              }

              item.productVariant = 'Default';
            }
          } catch (e) {
            // Fallback if product cannot be fetched
            item.productName = 'Product ${item.productId}';
          }
        }),
      );

      return cart;
    } catch (e) {
      throw Exception('Failed to fetch cart: $e');
    }
  }

  Future<void> updateQuantity(
    String userId,
    int productId,
    int quantity,
  ) async {
    try {
      final options = await _getAuthOptions();
      await _dio.put(
        '$_baseUrl/items/$productId',
        options: options,
        data: {'productId': productId, 'quantity': quantity},
      );
    } catch (e) {
      throw Exception('Failed to update quantity');
    }
  }

  Future<void> addItem(
    String userId,
    int productId,
    int quantity,
  ) async {
    try {
      final options = await _getAuthOptions();
      await _dio.post(
        '$_baseUrl/items',
        options: options,
        data: {'productId': productId, 'quantity': quantity},
      );
    } catch (e) {
      throw Exception('Failed to add item');
    }
  }

  Future<void> removeItem(String userId, int productId) async {
    try {
      final options = await _getAuthOptions();
      await _dio.delete('$_baseUrl/items/$productId', options: options);
    } catch (e) {
      throw Exception('Failed to remove item');
    }
  }
}
