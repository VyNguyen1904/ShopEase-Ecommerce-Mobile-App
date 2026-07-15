import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/favorite_service.dart';

import 'auth_provider.dart';

final favoriteServiceProvider = Provider((ref) {
  final authService = ref.watch(authServiceProvider);
  return FavoriteService(dio: authService.dio);
});

final favoriteProductsProvider = StateNotifierProvider<FavoriteProductsNotifier, AsyncValue<List<Product>>>((ref) {
  return FavoriteProductsNotifier(ref.watch(favoriteServiceProvider));
});

// A provider that just exposes a Set of product IDs for quick lookup (O(1)) in UI
final favoriteIdsProvider = Provider<Set<String>>((ref) {
  final productsAsync = ref.watch(favoriteProductsProvider);
  return productsAsync.maybeWhen(
    data: (products) => products.map((p) => p.id).toSet(),
    orElse: () => <String>{},
  );
});

class FavoriteProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final FavoriteService _service;

  FavoriteProductsNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final products = await _service.getFavorites();
      state = AsyncValue.data(products);
    } catch (e, st) {
      // If unauthorized or fail to load, just start with empty
      state = const AsyncValue.data([]);
    }
  }

  Future<void> toggleFavorite(Product product) async {
    final currentState = state;
    if (currentState is! AsyncData) return;

    final products = currentState.value ?? [];
    final isFavorite = products.any((p) => p.id == product.id);

    try {
      if (isFavorite) {
        // Optimistic update
        state = AsyncValue.data(products.where((p) => p.id != product.id).toList());
        await _service.removeFavorite(product.id);
      } else {
        // Optimistic update
        state = AsyncValue.data([...products, product]);
        await _service.addFavorite(product.id);
      }
    } catch (e) {
      // Revert if failed
      state = currentState;
      rethrow;
    }
  }
}
