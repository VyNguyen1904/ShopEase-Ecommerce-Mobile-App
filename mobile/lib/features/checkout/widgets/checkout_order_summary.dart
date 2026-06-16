import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class CheckoutOrderSummary extends StatelessWidget {
  final double subtotal;
  final double shippingFee;
  final double discount;
  final double totalAmount;

  const CheckoutOrderSummary({
    super.key,
    required this.subtotal,
    required this.shippingFee,
    required this.discount,
    required this.totalAmount,
  });

  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSummaryRow(AppStrings.subtotal, '${_formatPrice(subtotal)}đ'),
        const SizedBox(height: 8),
        _buildSummaryRow(AppStrings.shippingFee, '${_formatPrice(shippingFee)}đ'),
        const SizedBox(height: 8),
        _buildSummaryRow(AppStrings.discount, '-${_formatPrice(discount)}đ'),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              AppStrings.totalAmount,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            Text(
              '${_formatPrice(totalAmount)}đ',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.alertRed),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textGrey)),
        Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textDark, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
