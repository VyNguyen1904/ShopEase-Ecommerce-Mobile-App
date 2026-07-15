import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/cart_model.dart';
import '../../../core/services/cart_service.dart';
import '../../../core/providers/auth_provider.dart';

final cartServiceProvider = Provider((ref) {
  final authService = ref.watch(authServiceProvider);
  return CartService(dio: authService.dio);
});

final cartProvider =
    NotifierProvider<CartNotifier, AsyncValue<CartResponse>>(() {
      return CartNotifier();
    });

class CartNotifier extends Notifier<AsyncValue<CartResponse>> {
  late CartService _cartService;
  late String _userId;

  @override
  AsyncValue<CartResponse> build() {
    _cartService = ref.watch(cartServiceProvider);
    final userAsync = ref.watch(userProfileProvider);
    _userId = userAsync.value?.id ?? 'guest';
    
    if (_userId != 'guest') {
      // Fetch in background, return loading initially
      Future.microtask(() => fetchCart());
      return const AsyncValue.loading();
    } else {
      return AsyncValue.data(CartResponse(userId: 'guest', items: [], subtotal: 0, totalItems: 0));
    }
  }

  Future<void> fetchCart({bool silently = false}) async {
    try {
      if (!silently) {
        state = const AsyncValue.loading();
      }
      final cart = await _cartService.getCart(_userId);

      // Preserve selection state from current cart
      if (state.hasValue) {
        final currentItems = state.value!.items;
        for (var item in cart.items) {
          try {
            final existing = currentItems.firstWhere((e) => e.itemId == item.itemId);
            item.selected = existing.selected;
          } catch (_) {
            // New item, keeps default selected = true
          }
        }
        
        // Recalculate subtotal based on preserved selections
        final newSubtotal = cart.items
            .where((item) => item.selected)
            .fold(0.0, (sum, item) => sum + (item.price * item.quantity));
            
        final updatedCart = CartResponse(
          userId: cart.userId,
          items: cart.items,
          subtotal: newSubtotal,
          totalItems: cart.totalItems,
        );
        state = AsyncValue.data(updatedCart);
        return;
      }

      state = AsyncValue.data(cart);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    if (quantity < 1) {
      await removeItem(itemId);
      return;
    }

    // Optimistic UI update
    if (state.hasValue) {
      final currentCart = state.value!;
      final updatedItems = currentCart.items.map((item) {
        if (item.itemId == itemId) {
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
      final item = state.value?.items.firstWhere((e) => e.itemId == itemId);
      if (item != null) {
        await _cartService.updateQuantity(_userId, itemId, item.productId, quantity, item.color, item.size);
      }
      // Refresh to ensure server sync without showing loading spinner
      fetchCart(silently: true);
    } catch (e) {
      fetchCart(silently: true); // Revert on failure
    }
  }

  Future<void> addToCart(int productId, int quantity, {String? color, String? size}) async {
    try {
      await _cartService.addItem(_userId, productId, quantity, color: color, size: size);
      fetchCart(silently: true);
    } catch (e) {
      fetchCart(silently: true);
    }
  }

  Future<void> removeItem(String itemId) async {
    try {
      // Optimistic update
      if (state.hasValue) {
        final currentCart = state.value!;
        final updatedItems = currentCart.items
            .where((item) => item.itemId != itemId)
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

      await _cartService.removeItem(_userId, itemId);
      fetchCart(silently: true);
    } catch (e) {
      print('CartProvider removeItem Error: $e');
      fetchCart(silently: true);
    }
  }

  void toggleItemSelection(String itemId, bool selected) {
    if (state.hasValue) {
      final currentCart = state.value!;
      final updatedItems = currentCart.items.map((item) {
        if (item.itemId == itemId) {
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
