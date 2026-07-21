import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/cart_provider.dart';

class AppBottomNav extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final int cartCount = cartState.maybeWhen(
      data: (cart) => cart.items.fold(0, (sum, item) => sum + item.quantity),
      orElse: () => 0,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: NavigationBar(
              height: 64,
              selectedIndex: currentIndex,
              onDestinationSelected: onTap,
              backgroundColor: Colors.white,
              elevation: 0,
              indicatorColor: AppColors.primaryLight,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: AppStrings.navHome,
                ),
                const NavigationDestination(
                  icon: Icon(Icons.grid_view_outlined),
                  selectedIcon: Icon(Icons.grid_view),
                  label: AppStrings.navCategory,
                ),
                NavigationDestination(
                  icon: Badge(
                    label: Text(cartCount.toString()),
                    isLabelVisible: cartCount > 0,
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                  selectedIcon: Badge(
                    label: Text(cartCount.toString()),
                    isLabelVisible: cartCount > 0,
                    child: const Icon(Icons.shopping_cart),
                  ),
                  label: AppStrings.navCart,
                ),
                const NavigationDestination(
                  icon: Icon(Icons.assignment_outlined),
                  selectedIcon: Icon(Icons.assignment),
                  label: AppStrings.navOrders,
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: AppStrings.navProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
