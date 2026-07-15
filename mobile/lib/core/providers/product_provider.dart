import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/category_model.dart';
import '../services/product_service.dart';

import '../providers/auth_provider.dart';

final productServiceProvider = Provider<ProductService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return ProductService(dio: authService.dio);
});

/// Provider for fetching all products.
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final service = ref.watch(productServiceProvider);
  return service.getProducts();
});

final selectedCategoryHomeProvider = StateProvider<String?>((ref) => null);

/// Provider for New Arrivals
final newArrivalsProvider = FutureProvider<List<Product>>((ref) async {
  final products = await ref.watch(productsProvider.future);
  final selectedCategory = ref.watch(selectedCategoryHomeProvider);
  if (selectedCategory != null) {
    return products.where((p) => p.category == selectedCategory).take(6).toList();
  }
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
  final service = ref.watch(productServiceProvider);
  if (query.isEmpty) {
    return service.getProducts();
  }
  return service.searchProducts(query);
});

// ---------- Search Filter Providers ----------

/// Sort criteria: 'price', 'name', 'rating', 'salesCount', 'createdAt'
final sortByProvider = StateProvider<String>((ref) => 'none');

/// Sort direction: 'asc' or 'desc'
final sortDirProvider = StateProvider<String>((ref) => 'desc');

/// Selected category for search filtering (null = all categories)
final selectedCategorySearchProvider = StateProvider<String?>((ref) => null);

/// Price range filter
final minPriceProvider = StateProvider<double?>((ref) => null);
final maxPriceProvider = StateProvider<double?>((ref) => null);

/// Minimum rating filter
final minRatingProvider = StateProvider<double?>((ref) => null);

/// Count of active filters (for badge on "Bộ lọc" button)
final activeFilterCountProvider = Provider<int>((ref) {
  int count = 0;
  if (ref.watch(selectedCategorySearchProvider) != null) count++;
  if (ref.watch(minPriceProvider) != null || ref.watch(maxPriceProvider) != null) count++;
  if (ref.watch(minRatingProvider) != null) count++;
  if (ref.watch(sortByProvider) != 'none') count++;
  return count;
});

final filteredSearchProductsProvider = Provider.family<AsyncValue<List<Product>>, String>((ref, query) {
  final asyncProducts = ref.watch(searchProductsProvider(query));
  final sortBy = ref.watch(sortByProvider);
  final sortDir = ref.watch(sortDirProvider);
  final selectedCategory = ref.watch(selectedCategorySearchProvider);
  final minPrice = ref.watch(minPriceProvider);
  final maxPrice = ref.watch(maxPriceProvider);
  final minRating = ref.watch(minRatingProvider);

  return asyncProducts.whenData((products) {
    List<Product> filtered = List.from(products);

    // --- Category filter ---
    if (selectedCategory != null && selectedCategory.isNotEmpty) {
      filtered = filtered.where((p) => p.category == selectedCategory).toList();
    }

    // --- Price range filter ---
    if (minPrice != null) {
      filtered = filtered.where((p) => p.price >= minPrice).toList();
    }
    if (maxPrice != null) {
      filtered = filtered.where((p) => p.price <= maxPrice).toList();
    }

    // --- Rating filter ---
    if (minRating != null) {
      filtered = filtered.where((p) => p.rating >= minRating).toList();
    }

    // --- Sort ---
    if (sortBy != 'none') {
      filtered.sort((a, b) {
        int cmp;
        switch (sortBy) {
          case 'price':
            cmp = a.price.compareTo(b.price);
            break;
          case 'name':
            cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
            break;
          case 'rating':
            cmp = a.rating.compareTo(b.rating);
            break;
          case 'salesCount':
            cmp = a.salesCount.compareTo(b.salesCount);
            break;
          default:
            cmp = 0;
        }
        return sortDir == 'desc' ? -cmp : cmp;
      });
    }

    return filtered;
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
