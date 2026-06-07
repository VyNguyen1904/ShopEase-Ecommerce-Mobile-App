import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/product_service.dart';

final productServiceProvider = Provider((ref) => ProductService());

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final productService = ref.watch(productServiceProvider);
  final products = await productService.getProducts(page: 0, size: 20);
  return products;
});

/// Provider for New Arrivals
final newArrivalsProvider = FutureProvider<List<Product>>((ref) async {
  final products = await ref.watch(productsProvider.future);
  return products.take(6).toList();
});

/// Provider for Banner / Promotions
final promotionsProvider = FutureProvider<List<Product>>((ref) async {
  final products = await ref.watch(productsProvider.future);
  final discounted = products.where((p) => p.originalPrice != null && p.originalPrice! > p.price).toList();
  discounted.sort((a, b) => b.discountPercentage.compareTo(a.discountPercentage));
  
  // Nếu không có sản phẩm giảm giá, lấy 2 sản phẩm đầu tiên làm banner tạm
  if (discounted.isEmpty && products.isNotEmpty) {
    return products.take(2).toList();
  }
  return discounted.take(3).toList();
});


/// Provider for Recommendations
final recommendationsProvider = FutureProvider<List<Product>>((ref) async {
  final products = await ref.watch(productsProvider.future);
  return products.length > 6 ? products.reversed.take(6).toList() : products.reversed.toList();
});

/// Provider for a specific category
final categoryProductsProvider = FutureProvider.family<List<Product>, String>((
  ref,
  categoryName,
) async {
  // TODO: Call API endpoint with category filter
  // final response = await apiClient.get('/products?category=$categoryName');

  final products = await ref.watch(productsProvider.future);
  if (categoryName == 'Tất cả') return products;

  return products.where((p) => p.category == categoryName).toList();
});

