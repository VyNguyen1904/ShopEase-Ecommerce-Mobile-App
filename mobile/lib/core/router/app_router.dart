import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/shell/screens/shell_layout.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/category/screens/category_screen.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/notifications/screens/notification_screen.dart';
import '../../features/profile/screens/account_screen.dart';
import '../../features/orders/screens/orders_screen.dart';
import '../../features/checkout/screens/checkout_screen.dart';
import '../../features/orders/screens/order_detail_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/chat/screens/chat_list_screen.dart';
import '../../features/product/screens/product_detail_screen.dart';
import '../../features/home/screens/search_results_screen.dart';
import '../../features/profile/screens/address_screen.dart';
import '../../features/profile/screens/profile_edit_screen.dart';
import '../../features/admin/screens/admin_dashboard.dart';
import '../../features/admin/screens/admin_users.dart';
import '../../features/admin/screens/seller_order_detail.dart';
import '../../features/admin/screens/seller_notifications.dart';
import '../../features/seller/screens/seller_shop_profile.dart';
import '../../features/seller/screens/seller_dashboard_screen.dart';
import '../../features/seller/screens/seller_products_screen.dart';
import '../../features/seller/screens/seller_add_product_screen.dart';
import '../../features/seller/screens/seller_orders_screen.dart';

Map<String, dynamic> _decodeJwt(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return {};
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return json.decode(decoded) as Map<String, dynamic>;
  } catch (_) {
    return {};
  }
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final location = state.matchedLocation;
    final isAdminPath = location.startsWith('/admin');
    final isSellerPath = location.startsWith('/seller');

    if (isAdminPath || isSellerPath) {
      if (token == null || token.isEmpty) {
        return AppRoutes.login;
      }

      final payload = _decodeJwt(token);
      final role = payload['role'] as String?;

      if (isAdminPath && role != 'ADMIN') {
        return AppRoutes.home;
      }
      if (isSellerPath && role != 'SELLER' && role != 'ADMIN') {
        return AppRoutes.home;
      }
    }
    return null;
  },
  routes: [
    // ── Onboarding & Auth ──────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
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
        // Tab 2: Cart
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.cart,
              builder: (context, state) => const CartScreen(),
            ),
          ],
        ),
        // Tab 3: Orders (placeholder)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.orders,
              builder: (context, state) => const OrdersScreen(),
            ),
          ],
        ),
        // Tab 4: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.account,
              builder: (context, state) => const AccountScreen(),
            ),
          ],
        ),
      ],
    ),

    // ── Detail Screens (pushed on top, no bottom nav) ────────────────────
    GoRoute(
      path: AppRoutes.checkout,
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: AppRoutes.orderDetail,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return OrderDetailScreen(orderId: id);
      },
    ),
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
      path: AppRoutes.address,
      builder: (context, state) => const AddressScreen(),
    ),
    GoRoute(
      path: AppRoutes.profileEdit,
      builder: (context, state) => const ProfileEditScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),

    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => const NotificationScreen(),
    ),
    GoRoute(
      path: AppRoutes.chats,
      builder: (context, state) => const ChatListScreen(),
    ),

    // ── Admin & Seller Screens ─────────────────────────────────────────────
    GoRoute(
      path: '/admin',
      redirect: (context, state) => AppRoutes.adminDashboard,
    ),
    GoRoute(
      path: AppRoutes.adminDashboard,
      builder: (context, state) => const AdminDashboard(),
    ),
    GoRoute(
      path: AppRoutes.adminUsers,
      builder: (context, state) => const UserDirectoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.sellerOrderDetail,
      builder: (context, state) => const SellerOrderDetail(),
    ),
    GoRoute(
      path: AppRoutes.sellerNotifications,
      builder: (context, state) => const SellerNotifications(),
    ),
    GoRoute(
      path: AppRoutes.sellerShopProfile,
      builder: (context, state) => const SellerShopProfile(),
    ),
    GoRoute(
      path: AppRoutes.sellerDashboard,
      builder: (context, state) => const SellerDashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.sellerProducts,
      builder: (context, state) => const SellerProductsScreen(),
    ),
    GoRoute(
      path: AppRoutes.sellerAddProduct,
      builder: (context, state) => const SellerAddProductScreen(),
    ),
    GoRoute(
      path: AppRoutes.sellerOrders,
      builder: (context, state) => const SellerOrdersScreen(),
    ),
  ],
);


