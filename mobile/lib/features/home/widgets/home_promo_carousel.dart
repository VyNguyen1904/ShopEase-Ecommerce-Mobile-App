import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import 'promo_card.dart';

class HomePromoCarousel extends StatelessWidget {
  const HomePromoCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: const [
          PromoCard(
            title: AppStrings.promo1Title,
            subtitle: AppStrings.promo1Subtitle,
            description: AppStrings.promo1Desc,
            buttonText: AppStrings.buyNow,
            image:
                'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&q=80&w=400',
            color: Color(0xFF1A1A1A), // Đen tuyền sang trọng
          ),
          SizedBox(width: 16),
          PromoCard(
            title: AppStrings.promo2Title,
            subtitle: AppStrings.promo2Subtitle,
            description: AppStrings.promo2Desc,
            buttonText: AppStrings.viewCollection,
            image:
                'https://images.unsplash.com/photo-1544441893-675973e31985?auto=format&fit=crop&q=80&w=400',
            color: Color(0xFF4A3E3D), // Nâu tây sang trọng
          ),
        ],
      ),
    );
  }
}
