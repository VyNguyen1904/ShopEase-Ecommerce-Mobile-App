/// Centralized route name constants — avoids magic strings across the app.
abstract class AppRoutes {
  // Onboarding & auth
  static const String splash = '/splash';
  static const String register = '/register';

  // Main shell (bottom nav)
  static const String home = '/home';
  static const String category = '/category';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String notifications = '/notifications';

  // Detail screens (pushed on top of shell)
  static const String productDetail = '/product/:id';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String account = '/account';
  static const String chats = '/chats';

  // Admin & Seller screens
  static const String adminDashboard = '/admin/dashboard';
  static const String adminOrders = '/admin/orders';
  static const String adminUsers = '/admin/users';
  static const String sellerOrderDetail = '/seller/order-detail';
  static const String sellerNotifications = '/seller/notifications';
  static const String sellerShopProfile = '/seller/shop-profile';

  /// Build the product detail path with a given product id.
  static String productDetailPath(String id) => '/product/$id';
}
