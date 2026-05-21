import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -10),
          )
        ],
      ),
      child: Material(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(context, Icons.home_outlined, Icons.home_filled, 'Trang chủ', 0, '/home'),
                _buildNavItem(context, Icons.grid_view_rounded, Icons.grid_view_rounded, 'Danh mục', 1, ''),
                _buildNavItem(context, Icons.shopping_cart_outlined, Icons.shopping_cart, 'Giỏ hàng', 2, ''),
                _buildNavItem(context, Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Đơn hàng', 3, '/orders'),
                _buildNavItem(context, Icons.person_outline, Icons.person, 'Tài khoản', 4, ''),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, IconData activeIcon, String label, int index, String route) {
    final isActive = currentIndex == index;
    return InkWell(
      onTap: () {
        if (!isActive && route.isNotEmpty) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? const Color(0xFF2E6582) : const Color(0xFF9CA3AF),
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFF2E6582) : const Color(0xFF9CA3AF),
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
