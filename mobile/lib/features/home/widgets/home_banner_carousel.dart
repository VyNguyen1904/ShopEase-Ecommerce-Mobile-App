import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../../core/constants/app_colors.dart';

class HomeBannerCarousel extends StatelessWidget {
  const HomeBannerCarousel({super.key});

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
              'Sự kết hợp hoàn hảo giữa phong\ncách cổ điển và công nghệđệm\nAir hiện đại, mang lại cảm giác\nêm ái suốt cả ngày.',
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
              'Hiệu năng vượt trội với chip M3 Max thế hệmới. Trải nghiệm làm việc chuyên nghiệp chưa từng có.',
          buttonText: 'MUA NGAY',
          image:
              'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400&auto=format&fit=crop&q=80',
          color: const Color(0xFF2C3E50),
        ),
        _buildPromoCard(
          title: 'SONY',
          subtitle: 'Tai Nghe\nChống Ồn',
          description:
              'Đắm chìm trong không gian âm nhạc tĩnh lặng với công nghệchống ồn chủ động hàng đầu thế giới.',
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
