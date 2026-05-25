import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 1.0;
  bool _isNavigating = false;

  void _startNavigation() {
    if (_isNavigating) return;
    setState(() {
      _isNavigating = true;
      _opacity = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        onEnd: () {
          if (_isNavigating) {
            context.go(AppRoutes.home);
          }
        },
        child: Stack(
          children: [
            // Background gradient matching Customer/1.png
            Container(
              // Size constraints
              width: double.infinity,
              height: double.infinity,
              // Background decoration
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF045A60),
                    Color(0xFF0A757D),
                    Color(0xFF169E96),
                  ],
                ),
              ),
            ),
            Opacity(
              opacity: 0.35,
              child: Image.network(
                'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1080&auto=format&fit=crop&q=80',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  // How to position children along the MAIN axis (vertical for Column)
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 40), // Spacer
                    // App Logo & Brand Slogan
                    Column(
                      // How to size children along the MAIN axis
                      // MainAxisSize.min — shrink to fit children
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
                                color: Colors.black.withOpacity(0.12),
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
                          'ShopEase',
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
                          'Mua sắm thông minh,\ncuộc sống dễ dàng',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.9),
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
                        // Welcome Button → navigate with go_router
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                alignment: Alignment.center,
                                // Rich Text — multiple styles in one text block
                                child: RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    children: [
                                      TextSpan(text: 'Chào mừng bạn đến với '),
                                      TextSpan(
                                        text: 'ShopEase',
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
          ],
        ),
      ),
    );
  }
}
