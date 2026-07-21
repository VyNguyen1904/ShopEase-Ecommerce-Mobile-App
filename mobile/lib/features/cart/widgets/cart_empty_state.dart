import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class CartEmptyState extends StatelessWidget {
  const CartEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: AppColors.textLight,
          ),
          SizedBox(height: 16),
          Text(
            AppStrings.cartEmpty,
            style: TextStyle(color: AppColors.textGrey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
