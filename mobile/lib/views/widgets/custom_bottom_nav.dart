import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                context,
                Icons.home_outlined,
                Icons.home,
                'Trang chủ',
                0,
                '/home',
              ),
              _buildNavItem(
                context,
                Icons.shopping_cart_outlined,
                Icons.shopping_cart,
                'Giỏ hàng',
                1,
                '/cart',
              ),
              _buildNavItem(
                context,
                Icons.receipt_long_outlined,
                Icons.receipt_long,
                'Đơn hàng',
                2,
                '/orders',
              ),
              _buildNavItem(
                context,
                Icons.person_outline,
                Icons.person,
                'Tài khoản',
                3,
                '',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
    String route,
  ) {
    final isActive = currentIndex == index;
    final isCart = index == 2;

    return InkWell(
      onTap: () {
        if (!isActive && route.isNotEmpty) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: isActive ? const EdgeInsets.all(8) : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF2E6582)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isActive ? activeIcon : icon,
                    color: isActive ? Colors.white : const Color(0xFF4B5563),
                    size: isActive ? 20 : 24,
                  ),
                ),
                if (isCart)
                  Positioned(
                    right: isActive ? 4 : -4,
                    top: isActive ? 4 : -4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE88B41),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? const Color(0xFF2E6582)
                    : const Color(0xFF4B5563),
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
