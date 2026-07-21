import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/product.dart';
import '../../../core/providers/review_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';

class ProductInfo extends ConsumerWidget {
  final Product product;

  const ProductInfo({super.key, required this.product});

  String _formatCurrency(double amount) {
    String value = amount.round().toString();
    RegExp reg = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
    return value.replaceAllMapped(reg, (Match match) => '${match[1]}.');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(productReviewsProvider(product.id));

    // Calculate actual rating and review count from fetched reviews
    double displayRating = product.rating;
    int displayReviewCount = product.reviewsCount;

    reviewsAsync.whenData((reviews) {
      if (reviews.isNotEmpty) {
        displayReviewCount = reviews.length;
        displayRating =
            reviews.map((r) => r.rating).reduce((a, b) => a + b) /
            reviews.length;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          product.category,
          style: const TextStyle(fontSize: 16, color: AppColors.textGrey),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  index < displayRating.floor()
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '($displayReviewCount ${AppStrings.reviewsCountSuffix}',
              style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
            ),
            const Spacer(),
            Text(
              '${product.salesCount}${AppStrings.soldSuffix}',
              style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              '${_formatCurrency(product.price)}${AppStrings.currencySymbol}',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
            if (product.originalPrice != null &&
                product.discountPercentage > 0) ...[
              const SizedBox(width: 12),
              Text(
                '${_formatCurrency(product.originalPrice!)}${AppStrings.currencySymbol}',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textLight,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '-${product.discountPercentage}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          AppStrings.productDescTitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.description,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textGrey,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.storefront, color: Colors.blue, size: 24),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xem trực tiếp tại cửa hàng',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Bấm để xem bản đồ và chỉ đường',
                      style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  context.push(AppRoutes.storeMap);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Bản đồ',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
