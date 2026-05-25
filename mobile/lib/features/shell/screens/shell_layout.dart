import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_routes.dart';

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
              tooltip: 'Duyệt nhanh màn hình',
              child: const Icon(Icons.developer_mode),
              onPressed: () => _showDevPanel(context),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
        elevation: 8,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: 'Danh mục',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Giỏ hàng',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Đơn hàng',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.alertRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            activeIcon: const Icon(Icons.notifications),
            label: 'Thông báo',
          ),
        ],
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
                      'Bảng điều khiển kiểm thử giao diện',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Chọn nhanh một màn hình từ thiết kế PNG để đối chiếu:',
                  style: TextStyle(fontSize: 13, color: AppColors.textGrey),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    controller: controller,
                    children: [
                      _buildPanelSection('1. Luồng Chào Mừng & Đăng ký', [
                        _buildPanelItem(ctx, 'Splash Screen (Customer/1.png)',
                            () => context.go(AppRoutes.splash)),
                        _buildPanelItem(ctx, 'Onboarding (Customer/2.png)',
                            () => context.go(AppRoutes.onboarding)),
                        _buildPanelItem(ctx, 'Register (Customer/4.png)',
                            () => context.go(AppRoutes.register)),
                      ]),
                      _buildPanelSection('2. Trang mua sắm chính', [
                        _buildPanelItem(ctx, 'Home Screen (Customer/5.png)',
                            () => context.go(AppRoutes.home)),
                        _buildPanelItem(ctx, 'Search Results (Customer/6.png)',
                            () => context.push(AppRoutes.search)),
                        _buildPanelItem(
                            ctx, 'Product Detail (Customer/7.png)', () {
                          context.push(AppRoutes.productDetailPath('p1'));
                        }),
                      ]),
                      _buildPanelSection(
                          '3. Màn hình chung (Common Screens)', [
                        _buildPanelItem(ctx, 'Categories (Common_Sceen/2.png)',
                            () => context.go(AppRoutes.category)),
                        _buildPanelItem(
                            ctx,
                            'Notifications (Common_Sceen/1.png)',
                            () => context.go(AppRoutes.notifications)),
                        _buildPanelItem(ctx, 'Settings (Common_Sceen/3.png)',
                            () => context.push(AppRoutes.settings)),
                        _buildPanelItem(ctx, 'Account (Common_Sceen/4.png)',
                            () => context.push(AppRoutes.account)),
                        _buildPanelItem(ctx, 'Chat List (Common_Sceen/6.png)',
                            () => context.push(AppRoutes.chats)),
                      ]),
                      _buildPanelSection(
                          '4. Quản trị & Người bán (Admin & Seller)', [
                        _buildPanelItem(
                            ctx,
                            'Admin Dashboard (Admin/1.png)',
                            () => context.push(AppRoutes.adminDashboard)),
                        _buildPanelItem(
                            ctx,
                            'Admin Orders & Stock (Admin/2.png)',
                            () => context.push(AppRoutes.adminOrders)),
                        _buildPanelItem(
                            ctx,
                            'Admin User Management (Admin/3.png)',
                            () => context.push(AppRoutes.adminUsers)),
                        _buildPanelItem(
                            ctx,
                            'Seller Order Detail (Seller/1.png)',
                            () => context.push(AppRoutes.sellerOrderDetail)),
                        _buildPanelItem(
                            ctx,
                            'Seller Notifications (Seller/2.png)',
                            () => context.push(AppRoutes.sellerNotifications)),
                      ]),
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
                color: AppColors.primary),
          ),
        ),
        ...items,
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildPanelItem(
      BuildContext context, String name, VoidCallback onTap) {
    return Card(
      elevation: 0,
      color: AppColors.bgLight,
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(
          name,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark),
        ),
        dense: true,
        trailing: const Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
      ),
    );
  }
}
