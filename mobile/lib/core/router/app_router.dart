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
import '../../features/cart/screens/checkout_screen.dart';
import '../../features/orders/screens/order_detail_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/chat/screens/chat_list_screen.dart';
import '../../features/home/screens/product_detail_screen.dart';
import '../../features/home/screens/search_results_screen.dart';
import '../../features/profile/screens/address_screen.dart';
import '../../features/admin/screens/admin_dashboard.dart';
import '../../features/admin/screens/admin_orders.dart';
import '../../features/admin/screens/admin_users.dart';
import '../../features/admin/screens/seller_order_detail.dart';
import '../../features/admin/screens/seller_notifications.dart';
import '../../features/seller/screens/seller_shop_profile.dart';
import '../../features/seller/screens/seller_dashboard_screen.dart';

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
    GoRoute(
      path: AppRoutes.sellerShopProfile,
      builder: (context, state) => const SellerShopProfile(),
    ),
    GoRoute(
      path: AppRoutes.sellerDashboard,
      builder: (context, state) => const SellerDashboardScreen(),
    ),
  ],
);


