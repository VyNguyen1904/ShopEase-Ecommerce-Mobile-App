import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CheckoutSectionTitle extends StatelessWidget {
  final String title;
  const CheckoutSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
    );
  }
}
