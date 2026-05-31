import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';

/// Provider for fetching all products.
/// TODO: Replace the mock data with actual API calls (e.g., Dio or http).
final productsProvider = FutureProvider<List<Product>>((ref) async {
  // Simulated network delay to show loading state (remove when using real API)
  await Future.delayed(const Duration(milliseconds: 600));
  return mockProducts;
});

/// Provider for New Arrivals
final newArrivalsProvider = FutureProvider<List<Product>>((ref) async {
  // TODO: Call a specific endpoint for new arrivals
  // final response = await apiClient.get('/products/new-arrivals');

  final products = await ref.watch(productsProvider.future);
  return products.take(6).toList(); // Mock logic
});

/// Provider for Recommendations
final recommendationsProvider = FutureProvider<List<Product>>((ref) async {
  // TODO: Call a specific endpoint for recommendations
  // final response = await apiClient.get('/products/recommendations');

  final products = await ref.watch(productsProvider.future);
  return products.reversed.take(6).toList(); // Mock logic
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

/// Provider for categories list
final categoriesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  // TODO: Replace with API call to get categories list
  // final response = await apiClient.get('/categories');

  await Future.delayed(const Duration(milliseconds: 300));
  return [
    {'name': 'Thời trang Nữ', 'icon': Icons.woman_outlined},
    {'name': 'Thời trang Nam', 'icon': Icons.man_outlined},
    {'name': 'Giày thể thao', 'icon': Icons.sports_kabaddi_outlined},
    {'name': 'Túi xách', 'icon': Icons.shopping_bag_outlined},
    {'name': 'Phụ kiện', 'icon': Icons.watch_outlined},
    {'name': 'Làm đẹp', 'icon': Icons.face_retouching_natural_outlined},
    {'name': 'Thể thao', 'icon': Icons.sports_tennis_outlined},
    {'name': 'Nước hoa', 'icon': Icons.water_drop_outlined},
  ];
});
