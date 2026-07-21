import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 1.0;
  bool _isNavigating = false;
  final AuthService _authService = AuthService();

  void _startNavigation() async {
    if (_isNavigating) return;

    // Check if token exists
    final token = await _authService.getAccessToken();

    setState(() {
      _isNavigating = true;
      _opacity = 0.0;
    });

    String nextRoute = AppRoutes.login;
    if (token != null) {
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          final normalized = base64Url.normalize(payload);
          final decoded = utf8.decode(base64Url.decode(normalized));
          final jwt = json.decode(decoded) as Map<String, dynamic>;
          final role = jwt['role'];
          if (role == 'SELLER') {
            nextRoute = AppRoutes.sellerDashboard;
          } else if (role == 'ADMIN') {
            nextRoute = AppRoutes.adminDashboard;
          } else {
            nextRoute = AppRoutes.home;
          }
        } else {
          nextRoute = AppRoutes.home;
        }
      } catch (e) {
        nextRoute = AppRoutes.home;
      }
    }

    // Wait for animation to finish before navigating
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) context.go(nextRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF045A60), Color(0xFF0A757D), Color(0xFF169E96)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 40),
                  // App Logo & Brand Slogan
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.shopping_bag,
                            size: 64,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        AppStrings.appName,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.splashSlogan,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                  // Bottom Indicators & Action Text
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 36),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _startNavigation,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          overlayColor: WidgetStateProperty.all(
                            Colors.transparent,
                          ),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              alignment: Alignment.center,
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  children: [
                                    TextSpan(text: AppStrings.splashWelcome),
                                    TextSpan(
                                      text: AppStrings.appName,
                                      style: TextStyle(
                                        color: Color(0xFF5CFDF5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
