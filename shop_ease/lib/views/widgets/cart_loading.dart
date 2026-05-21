import 'package:flutter/material.dart';

class CartLoadingOverlay extends StatefulWidget {
  const CartLoadingOverlay({super.key});

  @override
  State<CartLoadingOverlay> createState() => _CartLoadingOverlayState();
}

class _CartLoadingOverlayState extends State<CartLoadingOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _slideAnimation = Tween<double>(begin: -1.2, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withValues(alpha: 0.95), // Nền trắng mờ
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animation Giỏ hàng chạy qua chạy lại
              SizedBox(
                height: 60,
                width: 200, // Độ rộng đường ray
                child: AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (context, child) {
                    return Align(
                      alignment: Alignment(_slideAnimation.value, 0),
                      child: const Icon(
                        Icons.shopping_cart,
                        size: 48,
                        color: Color(0xFF1E3A8A), // Xanh đậm sang trọng
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              // Thanh loading bar ở dưới
              Container(
                height: 4,
                width: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _controller.value,
                        child: Container(color: const Color(0xFF1E3A8A)),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Đang tải dữ liệu...',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374151),
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Vui lòng đợi trong giây lát để chúng\ntôi chuẩn bị trải nghiệm tốt nhất\ncho bạn.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
