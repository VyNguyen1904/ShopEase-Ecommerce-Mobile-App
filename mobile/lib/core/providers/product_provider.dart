import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/category_model.dart';
import '../services/product_service.dart';

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

/// Provider for fetching all products.
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final service = ref.watch(productServiceProvider);
  return service.getProducts();
});

/// Provider for New Arrivals
final newArrivalsProvider = FutureProvider<List<Product>>((ref) async {
  final products = await ref.watch(productsProvider.future);
  return products.take(6).toList(); 
});

/// Provider for Recommendations
final recommendationsProvider = FutureProvider<List<Product>>((ref) async {
  final products = await ref.watch(productsProvider.future);
  return products.reversed.take(6).toList(); 
});

/// Provider for a specific category
final categoryProductsProvider = FutureProvider.family<List<Product>, String>((
  ref,
  categoryName,
) async {
  final products = await ref.watch(productsProvider.future);
  if (categoryName == 'Tất cả') return products;

  return products.where((p) => p.category == categoryName).toList();
});

/// Provider for categories list
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final service = ref.watch(productServiceProvider);
  return service.getCategories();
});

final searchProductsProvider = FutureProvider.family<List<Product>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final service = ref.watch(productServiceProvider);
  return service.searchProducts(query);
});

final sortOrderProvider = StateProvider<String>((ref) => 'none');

final filteredSearchProductsProvider = Provider.family<AsyncValue<List<Product>>, String>((ref, query) {
  final asyncProducts = ref.watch(searchProductsProvider(query));
  final sortOrder = ref.watch(sortOrderProvider);

  return asyncProducts.whenData((products) {
    List<Product> sorted = List.from(products);
    if (sortOrder == 'asc') {
      sorted.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortOrder == 'desc') {
      sorted.sort((a, b) => b.price.compareTo(a.price));
    }
    return sorted;
  });
});

final productDetailProvider = FutureProvider.family<Product, String>((ref, id) async {
  final service = ref.watch(productServiceProvider);
  return service.getProductById(id);
});

final sellerProductsProvider = FutureProvider.family<List<Product>, String>((ref, sellerId) async {
  final service = ref.watch(productServiceProvider);
  return service.getProductsBySeller(sellerId);
});
