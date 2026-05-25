import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/shell/screens/shell_layout.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/shell/screens/category_screen.dart';
import '../../features/shell/screens/notification_screen.dart';
import '../../features/shell/screens/account_screen.dart';
import '../../features/shell/screens/settings_screen.dart';
import '../../features/shell/screens/chat_list_screen.dart';
import '../../features/home/screens/product_detail_screen.dart';
import '../../features/home/screens/search_results_screen.dart';
import '../../features/admin/screens/admin_dashboard.dart';
import '../../features/admin/screens/admin_orders.dart';
import '../../features/admin/screens/admin_users.dart';
import '../../features/admin/screens/seller_order_detail.dart';
import '../../features/admin/screens/seller_notifications.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  routes: [
    // ── Onboarding & Auth ──────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),

    // ── Main Shell with Bottom Navigation ─────────────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ShellLayout(navigationShell: navigationShell),
      branches: [
        // Tab 0: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Tab 1: Category
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.category,
              builder: (context, state) => const CategoryScreen(),
            ),
          ],
        ),
        // Tab 2: Cart (placeholder)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.cart,
              builder: (context, state) => const _PlaceholderScreen(
                icon: Icons.shopping_cart_outlined,
                label: 'Giỏ hàng (Trống)',
              ),
            ),
          ],
        ),
        // Tab 3: Orders (placeholder)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.orders,
              builder: (context, state) => const _PlaceholderScreen(
                icon: Icons.assignment_outlined,
                label: 'Đơn hàng (Trống)',
              ),
            ),
          ],
        ),
        // Tab 4: Notifications
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.notifications,
              builder: (context, state) => const NotificationScreen(),
            ),
          ],
        ),
      ],
    ),

    // ── Detail Screens (pushed on top, no bottom nav) ────────────────────
    GoRoute(
      path: AppRoutes.productDetail,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ProductDetailScreen(productId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.search,
      builder: (context, state) => const SearchResultsScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.account,
      builder: (context, state) => const AccountScreen(),
    ),
    GoRoute(
      path: AppRoutes.chats,
      builder: (context, state) => const ChatListScreen(),
    ),

    // ── Admin & Seller Screens ─────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.adminDashboard,
      builder: (context, state) => const AdminDashboard(),
    ),
    GoRoute(
      path: AppRoutes.adminOrders,
      builder: (context, state) => const AdminOrders(),
    ),
    GoRoute(
      path: AppRoutes.adminUsers,
      builder: (context, state) => const AdminUsers(),
    ),
    GoRoute(
      path: AppRoutes.sellerOrderDetail,
      builder: (context, state) => const SellerOrderDetail(),
    ),
    GoRoute(
      path: AppRoutes.sellerNotifications,
      builder: (context, state) => const SellerNotifications(),
    ),
  ],
);

/// Simple placeholder for tabs not yet implemented (Cart, Orders).
class _PlaceholderScreen extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PlaceholderScreen({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: const Color(0xFF94A3B8)),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
