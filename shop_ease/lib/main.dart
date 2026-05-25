import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'dart:ui';
import 'views/splash_screen.dart';
import 'views/home_screen.dart';
import 'views/login_screen.dart';
import 'views/register_screen.dart';
import 'views/onboarding_screen.dart';
import 'views/product_detail_screen.dart';
import 'views/orders_screen.dart';
import 'views/notifications_screen.dart';
import 'views/search_screen.dart';
import 'views/cart_screen.dart';
import 'views/checkout_screen.dart';
import 'views/payment_success_screen.dart';
import 'utils/app_colors.dart';

void main() {
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShopEase',
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.trackpad,
        },
      ),
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          onPrimary: AppColors.white,
          secondary: AppColors.accent,
          surface: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/product-detail': (context) => const ProductDetailScreen(),
        '/orders': (context) => const OrdersScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/search': (context) => const SearchScreen(),
        '/cart': (context) => const CartScreen(),
        '/checkout': (context) => const CheckoutScreen(),
        '/payment-success': (context) => const PaymentSuccessScreen(),
      },
    );
  }
}
