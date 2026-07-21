import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../../features/onboarding/screens/splash_screen.dart';
import '../models/cart_model.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/verification_screen.dart';
import '../../features/shell/screens/shell_layout.dart';
import '../../features/home/screens/home_screen.dart';
import '../models/product.dart';
import '../../features/category/screens/category_screen.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/notifications/screens/notification_screen.dart';
import '../../features/profile/screens/account_screen.dart';
import '../../features/orders/screens/orders_screen.dart';
import '../../features/checkout/screens/checkout_screen.dart';
import '../../features/orders/screens/order_detail_screen.dart';
import '../../features/orders/screens/review_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/profile/screens/notification_settings_screen.dart';
import '../../features/chat/screens/chat_list_screen.dart';
import '../../features/chat/screens/chat_room_screen.dart';
import '../../features/product/screens/product_detail_screen.dart';
import '../../features/home/screens/search_results_screen.dart';
import '../../features/profile/screens/address_screen.dart';
import '../../features/profile/screens/wishlist_screen.dart';
import '../../features/profile/screens/profile_edit_screen.dart';
import '../../features/profile/screens/my_reviews_screen.dart';
import '../../features/admin/screens/admin_dashboard.dart';
import '../../features/admin/screens/admin_users.dart';
import '../../features/seller/screens/seller_order_detail.dart';
import '../../features/seller/screens/seller_notifications.dart';
import '../../features/seller/screens/seller_shop_profile.dart';
import '../../features/seller/screens/seller_dashboard_screen.dart';
import '../../features/seller/screens/seller_products_screen.dart';
import '../../features/seller/screens/seller_add_product_screen.dart';
import '../../features/seller/screens/seller_edit_product_screen.dart';
import '../../features/seller/screens/seller_orders_screen.dart';
import '../../features/seller/screens/seller_shell_layout.dart';
import '../../features/cart/screens/payment_screen.dart';
import '../../features/store/screens/store_map_screen.dart';

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

    // Paths that require a logged in user (any role)
    final isProtectedPath =
        location == AppRoutes.checkout ||
        location == AppRoutes.orders ||
        location == AppRoutes.review ||
        location.startsWith('/order-detail') ||
        location == AppRoutes.address ||
        location == AppRoutes.wishlist ||
        location == AppRoutes.settings ||
        location == AppRoutes.notifications ||
        location == AppRoutes.chats;

    // Check auth status
    final isAuthenticated = token != null && token.isNotEmpty;

    if (isAdminPath || isSellerPath || isProtectedPath) {
      if (!isAuthenticated) {
        return AppRoutes.login;
      }

      if (isAdminPath || isSellerPath) {
        final payload = _decodeJwt(token);
        final role = payload['role'] as String?;

        if (isAdminPath && role != 'ADMIN') {
          return AppRoutes.home;
        }
        if (isSellerPath && role != 'SELLER' && role != 'ADMIN') {
          return AppRoutes.home;
        }
      }
    }
    return null;
  },
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Phiên đăng nhập đã hết hạn hoặc trang không tồn tại.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.login),
            child: const Text('Quay lại Đăng nhập'),
          ),
        ],
      ),
    ),
  ),
  routes: [
    // ── Deep Link Handlers ──────────────────────────────────────────────────
    GoRoute(path: '/', redirect: (context, state) => AppRoutes.home),
    GoRoute(
      path: '/payment-return/:id',
      redirect: (context, state) {
        final id = state.pathParameters['id'];
        if (id != null && id.isNotEmpty) {
          return AppRoutes.orderDetailPath(id);
        }
        return AppRoutes.orders;
      },
    ),
    GoRoute(
      path: '/payment-return',
      redirect: (context, state) => AppRoutes.orders,
    ),

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
    GoRoute(
      path: AppRoutes.verification,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final email = extra?['email'] as String? ?? '';
        return VerificationScreen(email: email);
      },
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
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final directItems = extra?['directItems'] as List<CartItem>?;
        return CheckoutScreen(directItems: directItems);
      },
    ),
    GoRoute(
      path: AppRoutes.payment,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final orderId = extra?['orderId'] as String? ?? '';
        return PaymentScreen(orderId: orderId);
      },
    ),
    GoRoute(
      path: AppRoutes.storeMap,
      builder: (context, state) => const StoreMapScreen(),
    ),
    GoRoute(
      path: AppRoutes.orderDetail,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return OrderDetailScreen(orderId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.review,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final order = extra?['order'];
        return ReviewScreen(order: order);
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
      builder: (context, state) {
        final isSelecting = state.extra is Map
            ? (state.extra as Map)['isSelecting'] == true
            : false;
        return AddressScreen(isSelecting: isSelecting);
      },
    ),
    GoRoute(
      path: AppRoutes.profileEdit,
      builder: (context, state) => const ProfileEditScreen(),
    ),
    GoRoute(
      path: AppRoutes.wishlist,
      builder: (context, state) => const WishlistScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.notificationSettings,
      builder: (context, state) => const NotificationSettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.myReviews,
      builder: (context, state) => const MyReviewsScreen(),
    ),

    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => const NotificationScreen(),
    ),
    GoRoute(
      path: AppRoutes.chats,
      builder: (context, state) => const ChatListScreen(),
    ),
    GoRoute(
      path: '${AppRoutes.chats}/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ChatRoomScreen(roomId: id);
      },
    ),

    // ── Admin & Seller Screens ─────────────────────────────────────────────
    GoRoute(
      path: '/admin',
      redirect: (context, state) => AppRoutes.adminDashboard,
    ),
    GoRoute(
      path: '/seller',
      redirect: (context, state) => AppRoutes.sellerDashboard,
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
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return SellerOrderDetail(orderId: id);
      },
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
      path: AppRoutes.sellerAddProduct,
      builder: (context, state) => const SellerAddProductScreen(),
    ),
    GoRoute(
      path: AppRoutes.sellerEditProduct,
      builder: (context, state) {
        final product = state.extra as Product;
        return SellerEditProductScreen(product: product);
      },
    ),

    // ── Seller Shell with Bottom Navigation ────────────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          SellerShellLayout(navigationShell: navigationShell),
      branches: [
        // Tab 0: Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.sellerDashboard,
              builder: (context, state) => const SellerDashboardScreen(),
            ),
          ],
        ),
        // Tab 1: Products
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.sellerProducts,
              builder: (context, state) => const SellerProductsScreen(),
            ),
          ],
        ),
        // Tab 2: Orders
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.sellerOrders,
              builder: (context, state) => const SellerOrdersScreen(),
            ),
          ],
        ),
        // Tab 3: Chat
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/seller-chat',
              builder: (context, state) => const ChatListScreen(),
            ),
          ],
        ),
        // Tab 4: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/seller-account',
              builder: (context, state) => const AccountScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
