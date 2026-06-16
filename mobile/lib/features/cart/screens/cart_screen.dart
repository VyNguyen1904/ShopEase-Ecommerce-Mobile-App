import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_routes.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_empty_state.dart';
import '../widgets/cart_item_widget.dart';
import '../widgets/cart_bottom_checkout.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textDark,
            size: 20,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: const Text(
          AppStrings.navCart,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: cartState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.textDark),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(AppStrings.unknownError, style: TextStyle(color: Colors.red)),
              TextButton(
                onPressed: () => ref.read(cartProvider.notifier).fetchCart(),
                child: const Text(AppStrings.retry),
              ),
            ],
          ),
        ),
        data: (cart) {
          final cartItems = cart.items;
          final bool isAllSelected =
              cartItems.isNotEmpty && cartItems.every((item) => item.selected);

          return Column(
            children: [
              // Select All Checkbox
              if (cartItems.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isAllSelected,
                        onChanged: (bool? value) {
                          ref
                              .read(cartProvider.notifier)
                              .toggleAll(value ?? false);
                        },
                        activeColor: AppColors.textDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Text(
                        AppStrings.selectAll,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),

              // Cart Items
              Expanded(
                child: cartItems.isEmpty
                    ? const CartEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: cartItems.length,
                        separatorBuilder: (context, index) => _buildDottedDivider(),
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return CartItemWidget(item: item);
                        },
                      ),
              ),

              // Bottom Checkout Section
              if (cartItems.isNotEmpty)
                CartBottomCheckout(subtotal: cart.subtotal),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDottedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(
          30,
          (index) => Expanded(
            child: Container(
              height: 1,
              color: index.isEven ? AppColors.border : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}
