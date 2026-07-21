import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class CheckoutShippingOptions extends StatelessWidget {
  final String selectedShipping;
  final bool isFreeShipping;
  final ValueChanged<String> onChanged;

  const CheckoutShippingOptions({
    super.key,
    required this.selectedShipping,
    this.isFreeShipping = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          RadioListTile<String>(
            value: 'nhanh',
            groupValue: selectedShipping,
            onChanged: (val) => onChanged(val!),
            activeColor: AppColors.primary,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            title: const Text(
              AppStrings.fastShipping,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            secondary: isFreeShipping
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        '35.000đ',
                        style: TextStyle(
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.textGrey,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '0đ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  )
                : const Text(
                    '35.000đ',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
          ),
          const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: AppColors.border,
          ),
          RadioListTile<String>(
            value: 'tietkiem',
            groupValue: selectedShipping,
            onChanged: (val) => onChanged(val!),
            activeColor: AppColors.primary,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            title: const Text(
              AppStrings.ecoShipping,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            secondary: isFreeShipping
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        '15.000đ',
                        style: TextStyle(
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.textGrey,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '0đ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  )
                : const Text(
                    '15.000đ',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
          ),
        ],
      ),
    );
  }
}
