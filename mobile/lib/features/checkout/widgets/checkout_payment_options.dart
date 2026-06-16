import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class CheckoutPaymentOptions extends StatelessWidget {
  final String selectedPayment;
  final ValueChanged<String> onChanged;

  const CheckoutPaymentOptions({
    super.key,
    required this.selectedPayment,
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
          _buildPaymentRadio(
            'cod',
            AppStrings.codPayment,
            isSelected: selectedPayment == 'cod',
          ),
          const Divider(
            height: 1,
            indent: 50,
            endIndent: 16,
            color: AppColors.border,
          ),
          _buildPaymentRadio(
            'vnpay',
            AppStrings.vnpayPayment,
            isSelected: selectedPayment == 'vnpay',
          ),
          const Divider(
            height: 1,
            indent: 50,
            endIndent: 16,
            color: AppColors.border,
          ),
          _buildPaymentRadio(
            'momo',
            AppStrings.momoPayment,
            isSelected: selectedPayment == 'momo',
          ),
          const Divider(
            height: 1,
            indent: 50,
            endIndent: 16,
            color: AppColors.border,
          ),
          _buildPaymentRadio(
            'card',
            AppStrings.cardPayment,
            isSelected: selectedPayment == 'card',
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRadio(
    String value,
    String title, {
    String? subtitle,
    bool isSelected = false,
  }) {
    return RadioListTile<String>(
      value: value,
      groupValue: selectedPayment,
      onChanged: (val) => onChanged(val!),
      activeColor: AppColors.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      title: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textDark,
            fontWeight: FontWeight.w500,
          ),
          children: [
            TextSpan(text: title),
            if (subtitle != null) ...[
              const TextSpan(text: ' '),
              TextSpan(
                text: subtitle,
                style: const TextStyle(color: AppColors.textGrey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
