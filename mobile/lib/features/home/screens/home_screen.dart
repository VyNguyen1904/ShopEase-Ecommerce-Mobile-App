import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/providers/product_provider.dart';
import '../../../core/providers/selected_product_provider.dart';
import '../../../core/providers/category_provider.dart';
import '../widgets/home_product_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HomeHeader(),
              _HomeBannerCarousel(),
              SizedBox(height: 30),
              _HomeCategories(),
              SizedBox(height: 30),
              _HomeNewArrivals(),
              SizedBox(height: 30),
              _HomeRecommendations(),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                        style: TextStyle(color: AppColors.textLight, fontSize: 14),
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
            icon: Icons.notifications_outlined,
            onTap: () => context.push(AppRoutes.notifications),
            showBadge: true,
          ),
          const SizedBox(width: 10),
          _buildIconButton(icon: Icons.qr_code_scanner, onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool showBadge = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, color: AppColors.textDark, size: 22),
          ),
          if (showBadge)
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.alertRed,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HomeBannerCarousel extends StatelessWidget {
  const _HomeBannerCarousel();

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 250,
        autoPlay: true,
        enlargeCenterPage: true,
        autoPlayInterval: const Duration(seconds: 4),
        viewportFraction: 0.9,
      ),
      items: [
        _buildPromoCard(
          title: 'NIKE',
          subtitle: 'Nike Air Max\nPhiên Bản Mới',
          description:
              'Sự kết hợp hoàn hảo giữa phong\ncách cổ điển và công nghệ đệm\nAir hiện đại, mang lại cảm giác\nêm ái suốt cả ngày.',
          buttonText: 'GIẢM 20% | MUA NGAY',
          image:
              'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&auto=format&fit=crop&q=80',
          color: AppColors.primary,
        ),
        _buildPromoCard(
          title: 'ADIDAS',
          subtitle: 'Bộ sưu tập\nThu Đông 2026',
          description:
              'Đột phá phong cách với dòng\nsản phẩm mới nhất. Thiết kế\nthể thao, năng động và đầy\ncá tính.',
          buttonText: 'GIẢM 25% | MUA NGAY',
          image:
              'https://images.unsplash.com/photo-1511556532299-8f662fc26c06?w=400&auto=format&fit=crop&q=80',
          color: AppColors.accent,
        ),
        _buildPromoCard(
          title: 'APPLE',
          subtitle: 'MacBook Pro\nM3 Max 2026',
          description:
              'Hiệu năng vượt trội với chip M3 Max thế hệ mới. Trải nghiệm làm việc chuyên nghiệp chưa từng có.',
          buttonText: 'MUA NGAY',
          image:
              'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400&auto=format&fit=crop&q=80',
          color: const Color(0xFF2C3E50),
        ),
        _buildPromoCard(
          title: 'SONY',
          subtitle: 'Tai Nghe\nChống Ồn',
          description:
              'Đắm chìm trong không gian âm nhạc tĩnh lặng với công nghệ chống ồn chủ động hàng đầu thế giới.',
          buttonText: 'GIẢM 15% | MUA NGAY',
          image:
              'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?w=400&auto=format&fit=crop&q=80',
          color: const Color(0xFFE74C3C),
        ),
      ],
    );
  }

  Widget _buildPromoCard({
    required String title,
    required String subtitle,
    required String description,
    required String buttonText,
    required String image,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 10,
                      height: 1.4,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: -20,
              bottom: 20,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;
  
  const _SectionTitle({required this.title, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: onViewAll ?? () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Xem tất cả',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeCategories extends ConsumerWidget {
  const _HomeCategories();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _SectionTitle(
          title: 'Danh mục',
          onViewAll: () => context.go(AppRoutes.category),
        ),
        const SizedBox(height: 12),
        ref.watch(categoriesProvider).when(
          data: (categories) {
            if (categories.isEmpty) return const SizedBox();
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: categories.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      onTap: () => context.go(AppRoutes.category),
                      child: _buildCategoryPill(
                        cat.name, 
                        isActive: cat.id == categories.first.id,
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => const SizedBox(),
        ),
      ],
    );
  }

  Widget _buildCategoryPill(String label, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isActive ? Colors.transparent : Colors.grey.shade300,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.black : Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _HomeNewArrivals extends ConsumerWidget {
  const _HomeNewArrivals();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const _SectionTitle(title: 'Hàng mới về'),
        const SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: ref.watch(newArrivalsProvider).when(
            data: (products) => ListView.builder(
              padding: const EdgeInsets.only(left: 20),
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (context, index) {
                return HomeProductCard(
                  ref: ref,
                  product: products[index],
                  heroPrefix: 'new',
                  showDiscount: false,
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Lỗi: $err')),
          ),
        ),
      ],
    );
  }
}

class _HomeRecommendations extends ConsumerWidget {
  const _HomeRecommendations();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const _SectionTitle(title: 'Gợi ý cho bạn'),
        const SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: ref.watch(recommendationsProvider).when(
            data: (products) => ListView.builder(
              padding: const EdgeInsets.only(left: 20),
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (context, index) {
                return HomeProductCard(
                  ref: ref,
                  product: products[index],
                  heroPrefix: 'rec',
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Lỗi: $err')),
          ),
        ),
      ],
    );
  }
}
