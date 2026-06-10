import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/cart_model.dart';
import '../../../core/services/cart_service.dart';
import '../../../core/providers/auth_provider.dart';

final cartServiceProvider = Provider((ref) => CartService());

final cartProvider =
    StateNotifierProvider<CartNotifier, AsyncValue<CartResponse>>((ref) {
      final userAsync = ref.watch(userProfileProvider);
      final userId = userAsync.value?.id ?? 'guest';
      return CartNotifier(ref.watch(cartServiceProvider), userId);
    });

class CartNotifier extends StateNotifier<AsyncValue<CartResponse>> {
  final CartService _cartService;
  final String _userId;

  CartNotifier(this._cartService, this._userId) : super(const AsyncValue.loading()) {
    if (_userId != 'guest') {
      fetchCart();
    } else {
      state = AsyncValue.data(CartResponse(userId: 'guest', items: [], subtotal: 0, totalItems: 0));
    }
  }

  Future<void> fetchCart() async {
    try {
      state = const AsyncValue.loading();
      final cart = await _cartService.getCart(_userId);
      if (!mounted) return;
      state = AsyncValue.data(cart);
    } catch (e, st) {
      if (!mounted) return;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    if (quantity < 1) {
      await removeItem(productId);
      return;
    }

    // Optimistic UI update
    if (state.hasValue) {
      final currentCart = state.value!;
      final updatedItems = currentCart.items.map((item) {
        if (item.productId == productId) {
          item.quantity = quantity;
        }
        return item;
      }).toList();

      final newSubtotal = updatedItems
          .where((item) => item.selected)
          .fold(0.0, (sum, item) => sum + (item.price * item.quantity));

      state = AsyncValue.data(
        CartResponse(
          userId: currentCart.userId,
          items: updatedItems,
          subtotal: newSubtotal,
          totalItems: currentCart.totalItems,
        ),
      );
    }

    try {
      await _cartService.updateQuantity(_userId, productId, quantity);
      // Refresh to ensure server sync
      fetchCart();
    } catch (e) {
      fetchCart(); // Revert on failure
    }
  }

  Future<void> addToCart(int productId, int quantity) async {
    try {
      await _cartService.addItem(_userId, productId, quantity);
      fetchCart();
    } catch (e) {
      fetchCart();
    }
  }

  Future<void> removeItem(int productId) async {
    try {
      // Optimistic update
      if (state.hasValue) {
        final currentCart = state.value!;
        final updatedItems = currentCart.items
            .where((item) => item.productId != productId)
            .toList();
        final newSubtotal = updatedItems
            .where((item) => item.selected)
            .fold(0.0, (sum, item) => sum + (item.price * item.quantity));

        state = AsyncValue.data(
          CartResponse(
            userId: currentCart.userId,
            items: updatedItems,
            subtotal: newSubtotal,
            totalItems: currentCart.totalItems,
          ),
        );
      }

      await _cartService.removeItem(_userId, productId);
      fetchCart();
    } catch (e) {
      fetchCart();
    }
  }

  void toggleItemSelection(int productId, bool selected) {
    if (state.hasValue) {
      final currentCart = state.value!;
      final updatedItems = currentCart.items.map((item) {
        if (item.productId == productId) {
          item.selected = selected;
        }
        return item;
      }).toList();

      final newSubtotal = updatedItems
          .where((item) => item.selected)
          .fold(0.0, (sum, item) => sum + (item.price * item.quantity));

      state = AsyncValue.data(
        CartResponse(
          userId: currentCart.userId,
          items: updatedItems,
          subtotal: newSubtotal,
          totalItems: currentCart.totalItems,
        ),
      );
    }
  }

  void toggleAll(bool selected) {
    if (state.hasValue) {
      final currentCart = state.value!;
      final updatedItems = currentCart.items.map((item) {
        item.selected = selected;
        return item;
      }).toList();

      final newSubtotal = selected
          ? updatedItems.fold(
              0.0,
              (sum, item) => sum + (item.price * item.quantity),
            )
          : 0.0;

      state = AsyncValue.data(
        CartResponse(
          userId: currentCart.userId,
          items: updatedItems,
          subtotal: newSubtotal,
          totalItems: currentCart.totalItems,
        ),
      );
    }
  }
}
