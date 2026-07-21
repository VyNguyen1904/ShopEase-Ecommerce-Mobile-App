import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PriceRangeFilter extends StatelessWidget {
  final double minPrice;
  final double maxPrice;
  final ValueChanged<RangeValues> onChanged;
  final String Function(double) formatCurrency;

  const PriceRangeFilter({
    super.key,
    required this.minPrice,
    required this.maxPrice,
    required this.onChanged,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatCurrency(minPrice),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              Text(
                formatCurrency(maxPrice),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          RangeSlider(
            values: RangeValues(minPrice, maxPrice),
            min: 0,
            max: 10000000,
            divisions: 100,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.border,
            labels: RangeLabels(
              formatCurrency(minPrice),
              formatCurrency(maxPrice),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
