import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/review_provider.dart';

class ProductReviews extends ConsumerWidget {
  final String productId;

  const ProductReviews({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsyncValue = ref.watch(productReviewsProvider(productId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              AppStrings.productReviews,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Text(
              AppStrings.viewAll,
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
                  AppStrings.noReviewsYet,
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontStyle: FontStyle.italic,
                  ),
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
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        child: Text(
                          review.buyerId.isNotEmpty
                              ? review.buyerId[0].toUpperCase()
                              : 'U',
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
                            index < review.rating
                                ? Icons.star
                                : Icons.star_border,
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
              AppStrings.noReviewsYet,
              style: TextStyle(
                color: AppColors.textGrey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
