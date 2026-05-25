import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/product.dart';
import '../../../core/providers/selected_product_provider.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/countdown_timer.dart';
import '../../../core/widgets/product_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Search & Action Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.push(AppRoutes.search),
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.bgLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.search, color: AppColors.textLight, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Tìm kiếm sản phẩm, thương hiệu...',
                                  style: TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildIconButton(
                      icon: Icons.search,
                      onTap: () => context.push(AppRoutes.search),
                    ),
                    const SizedBox(width: 10),
                    _buildIconButton(
                      icon: Icons.qr_code_scanner,
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              // 2. Banner Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF034247), Color(0xFF0A6F75)],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'SIÊU GIẢM GIÁ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'GIẢM ĐẾN 90%',
                              style: TextStyle(
                                color: Color(0xFF5CFDF5),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Mua ngay',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 8,
                        bottom: 0,
                        top: 0,
                        child: Image.network(
                          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&auto=format&fit=crop&q=80',
                          width: 150,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildBannerDot(isActive: true),
                            const SizedBox(width: 4),
                            _buildBannerDot(isActive: false),
                            const SizedBox(width: 4),
                            _buildBannerDot(isActive: false),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 3. Quick Categories
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCategoryItem(
                      icon: Icons.headphones_outlined,
                      label: 'Điện tử',
                      color: const Color(0xFFFFECE5),
                      iconColor: const Color(0xFFFF5D2E),
                    ),
                    _buildCategoryItem(
                      icon: Icons.checkroom_outlined,
                      label: 'Thời trang',
                      color: const Color(0xFFE6F5F6),
                      iconColor: const Color(0xFF0A6F75),
                    ),
                    _buildCategoryItem(
                      icon: Icons.home_outlined,
                      label: 'Nhà cửa',
                      color: const Color(0xFFECEFFF),
                      iconColor: const Color(0xFF3B82F6),
                    ),
                    _buildCategoryItem(
                      icon: Icons.face_retouching_natural_outlined,
                      label: 'Làm đẹp',
                      color: const Color(0xFFFFF0F0),
                      iconColor: const Color(0xFFEF4444),
                    ),
                    _buildCategoryItem(
                      icon: Icons.grid_view_outlined,
                      label: 'Khác',
                      color: const Color(0xFFF1F5F9),
                      iconColor: const Color(0xFF64748B),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 4. Flash Sale Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Flash Sale',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(width: 12),
                        CountdownTimer(),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Xem tất cả',
                        style: TextStyle(
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 4b. Flash Sale Products
              SizedBox(
                height: 170,
                child: ListView.builder(
                  padding: const EdgeInsets.only(left: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    final product = mockProducts[index];
                    final heroTag = 'hero_flash_${product.id}';
                    return ProductCard(
                      product: product,
                      heroTag: heroTag,
                      onTap: () {
                        ref.read(selectedProductProvider.notifier).state = product;
                        ref.read(selectedHeroTagProvider.notifier).state = heroTag;
                        context.push(AppRoutes.productDetailPath(product.id));
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),

              // 5. Suggestions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Gợi ý cho bạn',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right,
                          color: AppColors.textGrey),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 3 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: mockProducts.length,
                  itemBuilder: (context, index) {
                    final product = mockProducts[index];
                    final heroTag = 'hero_suggest_${product.id}';
                    return ProductCard(
                      product: product,
                      heroTag: heroTag,
                      onTap: () {
                        ref.read(selectedProductProvider.notifier).state = product;
                        ref.read(selectedHeroTagProvider.notifier).state = heroTag;
                        context.push(AppRoutes.productDetailPath(product.id));
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(
      {required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: AppColors.textDark, size: 22),
      ),
    );
  }

  Widget _buildBannerDot({required bool isActive}) {
    return Container(
      width: isActive ? 16 : 6,
      height: 6,
      decoration: BoxDecoration(
        color:
            isActive ? Colors.white : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
