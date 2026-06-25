import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_routes.dart';
import '../widgets/app_bottom_nav.dart';

/// The main scaffold that holds the bottom navigation bar.
/// Used as the shell for StatefulShellRoute in go_router.
class ShellLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ShellLayout({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      // Return to the branch's initial location when re-tapping the active tab
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          navigationShell,
          // Floating dev review panel
          Positioned(
            bottom: 80,
            right: 16,
            child: FloatingActionButton.small(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              tooltip: AppStrings.devPanelTooltip,
              child: const Icon(Icons.developer_mode),
              onPressed: () => _showDevPanel(context),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }

  void _showDevPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (_, controller) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.developer_mode, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      AppStrings.devPanelTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  AppStrings.devPanelSubtitle,
                  style: TextStyle(fontSize: 13, color: AppColors.textGrey),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    controller: controller,
                    children: [
                      _buildPanelSection('1. Luồng Chào Mừng & Đăng ký', [
                        _buildPanelItem(
                          ctx,
                          'Splash Screen (Customer/1.png)',
                          () => context.go(AppRoutes.splash),
                        ),
                        _buildPanelItem(
                          ctx,
                          'Login (Customer/2.png)',
                          () => context.go(AppRoutes.login),
                        ),
                        _buildPanelItem(
                          ctx,
                          'Register (Customer/4.png)',
                          () => context.go(AppRoutes.register),
                        ),
                      ]),
                      _buildPanelSection('2. Trang mua sắm chính', [
                        _buildPanelItem(
                          ctx,
                          'Home Screen (Customer/5.png)',
                          () => context.go(AppRoutes.home),
                        ),
                        _buildPanelItem(
                          ctx,
                          'Search Results (Customer/6.png)',
                          () => context.push(AppRoutes.search),
                        ),
                        _buildPanelItem(
                          ctx,
                          'Product Detail (Customer/7.png)',
                          () {
                            context.push(AppRoutes.productDetailPath('p1'));
                          },
                        ),
                        _buildPanelItem(
                          ctx,
                          'Cart (Customer/3.png)',
                          () => context.go(AppRoutes.cart),
                        ),
                        _buildPanelItem(
                          ctx,
                          'Checkout (Customer/4.png)',
                          () => context.push(AppRoutes.checkout),
                        ),
                        _buildPanelItem(
                          ctx,
                          'Orders (Customer/8.png)',
                          () => context.go(AppRoutes.orders),
                        ),
                        _buildPanelItem(
                          ctx,
                          'Order Detail (Customer/9.png)',
                          () => context.push(
                            AppRoutes.orderDetailPath('SE2405150001'),
                          ),
                        ),
                        _buildPanelItem(
                          ctx,
                          'Address Screen (Customer/10.png)',
                          () => context.push(AppRoutes.address),
                        ),
                      ]),
                      _buildPanelSection('3. Màn hình chung (Common Screens)', [
                        _buildPanelItem(
                          ctx,
                          'Categories (Common_Sceen/2.png)',
                          () => context.go(AppRoutes.category),
                        ),
                        _buildPanelItem(
                          ctx,
                          'Notifications (Common_Sceen/1.png)',
                          () => context.go(AppRoutes.notifications),
                        ),
                        _buildPanelItem(
                          ctx,
                          'Settings (Common_Sceen/3.png)',
                          () => context.push(AppRoutes.settings),
                        ),
                        _buildPanelItem(
                          ctx,
                          'Account (Common_Sceen/4.png)',
                          () => context.push(AppRoutes.account),
                        ),
                        _buildPanelItem(
                          ctx,
                          'Chat List (Common_Sceen/6.png)',
                          () => context.push(AppRoutes.chats),
                        ),
                      ]),
                      _buildPanelSection(
                        '4. Quản trị(Admin)',
                        [
                          _buildPanelItem(
                            ctx,
                            'Admin Dashboard (Admin/1.png)',
                            () => context.push(AppRoutes.adminDashboard),
                          ),
                          _buildPanelItem(
                            ctx,
                            'Admin User Management (Admin/3.png)',
                            () => context.push(AppRoutes.adminUsers),
                          ),
                        ],
                      ),
                      _buildPanelSection(
                        '5. Người bán (Seller)',
                        [
                          _buildPanelItem(
                            ctx,
                            'Seller Order Detail (Seller/1.png)',
                            () => context.push(AppRoutes.sellerOrderDetail),
                          ),
                          _buildPanelItem(
                            ctx,
                            'Seller Notifications (Seller/2.png)',
                            () => context.push(AppRoutes.sellerNotifications),
                          ),
                          _buildPanelItem(
                            ctx,
                            'Seller Shop Profile (Seller/3.png)',
                            () => context.push(AppRoutes.sellerShopProfile),
                          ),
                          _buildPanelItem(
                            ctx,
                            'Seller Dashboard (Seller/Dashboard.png)',
                            () => context.push(AppRoutes.sellerDashboard),
                          ),
                          _buildPanelItem(
                            ctx,
                            'Seller Products',
                            () => context.push(AppRoutes.sellerProducts),
                          ),
                          _buildPanelItem(
                            ctx,
                            'Seller Add Product',
                            () => context.push(AppRoutes.sellerAddProduct),
                          ),
                          _buildPanelItem(
                            ctx,
                            'Seller Orders',
                            () => context.push(AppRoutes.sellerOrders),
                          ),
                          _buildPanelItem(
                            ctx,
                            'Seller Chat',
                            () => context.push(AppRoutes.chats),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPanelSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        ...items,
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildPanelItem(
    BuildContext context,
    String name,
    VoidCallback onTap,
  ) {
    // Card is a Material surface with elevation, rounded corners, and a shadow.
    return Card(
      // elevation: shadow depth (0 = flat, 8 = very elevated)
      elevation: 0,
      // color: background color
      color: AppColors.bgLight,
      margin: const EdgeInsets.only(bottom: 6),
      // shape: the outline of the card
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      // ListTile is a one-to-three line list item. It handles layout, padding, and touch feedback automatically.
      child: ListTile(
        tileColor: AppColors.bgLight,
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        // dense: reduces vertical height (good for compact lists)
        dense: true,
        // trailing: widget on the far right
        trailing: const Icon(
          Icons.arrow_forward,
          size: 14,
          color: AppColors.primary,
        ),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
      ),
    );
  }
}
