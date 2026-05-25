import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class CategoryScreen extends StatelessWidget {
  final VoidCallback onSearchTrigger;

  const CategoryScreen({super.key, required this.onSearchTrigger});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {'name': 'Điện tử', 'icon': Icons.monitor_outlined, 'color': const Color(0xFFEAF5F6), 'iconColor': const Color(0xFF0A6F75)},
      {'name': 'Thời trang', 'icon': Icons.checkroom_outlined, 'color': const Color(0xFFFFECE5), 'iconColor': const Color(0xFFFF5D2E)},
      {'name': 'Nhà cửa & Đời sống', 'icon': Icons.home_outlined, 'color': const Color(0xFFFFF2EE), 'iconColor': const Color(0xFFF59E0B)},
      {'name': 'Làm đẹp', 'icon': Icons.face_retouching_natural_outlined, 'color': const Color(0xFFFFF0F0), 'iconColor': const Color(0xFFEF4444)},
      {'name': 'Thể thao', 'icon': Icons.sports_tennis_outlined, 'color': const Color(0xFFE8F8EE), 'iconColor': const Color(0xFF10B981)},
      {'name': 'Giày dép', 'icon': Icons.shopping_bag_outlined, 'color': const Color(0xFFEEF2F6), 'iconColor': const Color(0xFF6366F1)},
      {'name': 'Phụ kiện', 'icon': Icons.watch_outlined, 'color': const Color(0xFFFFF7ED), 'iconColor': const Color(0xFFD97706)},
      {'name': 'Đồ chơi & Trò chơi', 'icon': Icons.smart_toy_outlined, 'color': const Color(0xFFFDF2F8), 'iconColor': const Color(0xFFDB2777)},
      {'name': 'Ô tô & Xe máy', 'icon': Icons.directions_car_filled_outlined, 'color': const Color(0xFFECFEFF), 'iconColor': const Color(0xFF0891B2)},
      {'name': 'Đồ dùng & Máy ảnh', 'icon': Icons.photo_camera_outlined, 'color': const Color(0xFFF5F3FF), 'iconColor': const Color(0xFF7C3AED)},
      {'name': 'Sản phẩm số', 'icon': Icons.sports_esports_outlined, 'color': const Color(0xFFECFDF5), 'iconColor': const Color(0xFF059669)},
      {'name': 'Xem thêm', 'icon': Icons.grid_view_outlined, 'color': const Color(0xFFF1F5F9), 'iconColor': const Color(0xFF475569)},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Danh mục',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textDark, size: 24),
            onPressed: onSearchTrigger,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: InkWell(
              onTap: onSearchTrigger, // Jump to search results for demo
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  // Icon container (matching Common_Sceen/2.png)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: cat['color'],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(cat['icon'], color: cat['iconColor'], size: 22),
                  ),
                  const SizedBox(width: 18),
                  // Category Name
                  Expanded(
                    child: Text(
                      cat['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  // Chevron right
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textLight,
                    size: 20,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
