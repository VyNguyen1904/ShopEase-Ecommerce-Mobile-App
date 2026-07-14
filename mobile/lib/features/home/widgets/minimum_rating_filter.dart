import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class MinimumRatingFilter extends StatelessWidget {
  final double currentRating;
  final ValueChanged<double> onChanged;

  const MinimumRatingFilter({
    super.key,
    required this.currentRating,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final starValue = index + 1.0;
              final isActive = starValue <= currentRating;
              return GestureDetector(
                onTap: () {
                  onChanged(currentRating == starValue ? 0 : starValue);
                },
                child: Icon(
                  isActive ? Icons.star : Icons.star_border,
                  size: 36,
                  color: isActive ? AppColors.accent : AppColors.textLight,
                ),
              );
            }),
          ),
          if (currentRating > 0) ...[
            const SizedBox(height: 8),
            Text(
              '${AppStrings.minRatingPrefix}${currentRating.toInt()}${AppStrings.minRatingSuffix}',
              style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
            ),
          ],
        ],
      ),
    );
  }
}
