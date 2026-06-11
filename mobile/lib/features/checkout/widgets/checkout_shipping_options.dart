import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CheckoutShippingOptions extends StatelessWidget {
  final String selectedShipping;
  final ValueChanged<String> onChanged;

  const CheckoutShippingOptions({
    super.key,
    required this.selectedShipping,
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
              'Nhanh (2–3 ngày)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            secondary: const Text(
              '32.000đ',
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
              'Tiết kiệm (3–5 ngày)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            secondary: const Text(
              '15.000đ',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
