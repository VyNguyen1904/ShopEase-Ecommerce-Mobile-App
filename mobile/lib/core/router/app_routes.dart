/// Centralized route name constants — avoids magic strings across the app.
abstract class AppRoutes {
  // Onboarding & auth
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';

  // Main shell (bottom nav)
  static const String home = '/home';
  static const String category = '/category';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String notifications = '/notifications';

  // Detail screens (pushed on top of shell)
  static const String productDetail = '/product/:id';
  static const String checkout = '/checkout';
  static const String orderDetail = '/order-detail/:id';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String account = '/account';
  static const String address = '/address';
  static const String chats = '/chats';

  // Admin & Seller screens
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String sellerOrderDetail = '/seller/order-detail/:id';
  static const String sellerNotifications = '/seller/notifications';
  static const String sellerShopProfile = '/seller/shop-profile';
  static const String sellerDashboard = '/seller/dashboard';
  static const String sellerProducts = '/seller/products';
  static const String sellerAddProduct = '/seller/add-product';
  static const String sellerOrders = '/seller/orders';

  static String productDetailPath(String id) => '/product/$id';
  static String orderDetailPath(String id) => '/order-detail/$id';
  static String sellerOrderDetailPath(String id) => '/seller/order-detail/$id';
  // Payment
  static const String payment = '/payment';
}
