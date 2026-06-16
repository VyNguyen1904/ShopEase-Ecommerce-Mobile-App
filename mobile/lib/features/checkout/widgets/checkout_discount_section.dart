import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class CheckoutDiscountSection extends StatelessWidget {
  final bool useCoins;
  final ValueChanged<bool> onUseCoinsChanged;

  const CheckoutDiscountSection({
    super.key,
    required this.useCoins,
    required this.onUseCoinsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: AppStrings.enterPromoCode,
                    hintStyle: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.bgLight,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Text(
                AppStrings.apply,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Checkbox(
              value: useCoins,
              onChanged: (val) => onUseCoinsChanged(val!),
              activeColor: AppColors.primary,
            ),
            RichText(
              text: const TextSpan(
                style: TextStyle(color: AppColors.textDark, fontSize: 14),
                children: [
                  TextSpan(text: AppStrings.useCoinsPrefix),
                  TextSpan(
                    text: AppStrings.coinsAmount,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.alertRed,
                    ),
                  ),
                  TextSpan(
                    text: AppStrings.coinsDiscount,
                    style: TextStyle(color: AppColors.alertRed),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Switch(
              value: useCoins,
              onChanged: onUseCoinsChanged,
              activeThumbColor: AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }
}
