import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/providers/selected_product_provider.dart';
import '../../../core/models/product.dart';

import '../widgets/product_options_selector.dart';
import '../widgets/product_bottom_bar.dart';
import '../../../core/providers/review_provider.dart';
import '../../../core/models/review.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final product = ref.watch(selectedProductProvider);
    final heroTag = ref.watch(selectedHeroTagProvider);

    if (product == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.textLight,
              ),
              const SizedBox(height: 12),
              const Text('Không tìm thấy sản phẩm'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppRoutes.home);
                  }
                },
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildImage(product.imageUrl, heroTag.isNotEmpty ? heroTag : 'hero_img_${product.id}_v'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfo(product),
                            ProductOptionsSelector(sizes: product.sizes),
                            _buildReviews(product.id),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ProductBottomBar(product: product),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.home);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.arrow_back_ios,
                color: AppColors.textDark,
                size: 22,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? AppColors.alertRed : AppColors.textDark,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String imageUrl, String heroTag) {
    return Container(
      width: double.infinity,
      height: 360,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Hero(
          tag: heroTag,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            cacheWidth: 800,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.image,
                size: 100,
                color: AppColors.textLight,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(Product product) {
    String formatCurrency(double amount) {
      String value = amount.round().toString();
      RegExp reg = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
      return value.replaceAllMapped(reg, (Match match) => '${match[1]}.');
    }

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
                  index < product.rating.floor() ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${product.reviewsCount} đánh giá)',
              style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
            ),
            const Spacer(),
            Text(
              '${product.salesCount} đã bán',
              style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              '${formatCurrency(product.price)}đ',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
            if (product.originalPrice != null) ...[
              const SizedBox(width: 12),
              Text(
                '${formatCurrency(product.originalPrice!)}đ',
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
          'Mô tả sản phẩm',
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
      ],
    );
  }

  Widget _buildReviews(String productId) {
    final reviewsAsyncValue = ref.watch(productReviewsProvider(productId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Đánh giá sản phẩm',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Text(
              'Xem tất cả',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        reviewsAsyncValue.when(
          data: (reviews) {
            if (reviews.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Chưa có đánh giá nào cho sản phẩm này.',
                  style: TextStyle(color: AppColors.textGrey, fontStyle: FontStyle.italic),
                ),
              );
            }
            // Display first review as a preview
            final review = reviews.first;
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          review.buyerId.isNotEmpty ? review.buyerId[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.buyerId,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < review.rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (review.title.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      review.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  if (review.body.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      review.body,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        height: 1.5,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Chưa có đánh giá nào cho sản phẩm này.',
              style: TextStyle(color: AppColors.textGrey, fontStyle: FontStyle.italic),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
