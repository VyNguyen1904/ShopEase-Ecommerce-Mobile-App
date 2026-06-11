import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CheckoutStepper extends StatelessWidget {
  const CheckoutStepper({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStepIndicator('1', isActive: true),
        _buildStepLine(),
        _buildStepIndicator('2', isActive: false),
        _buildStepLine(),
        _buildStepIndicator('3', isActive: false),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textGrey),
      ],
    );
  }

  Widget _buildStepIndicator(String number, {required bool isActive}) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.bgLight,
        shape: BoxShape.circle,
        border: isActive ? null : Border.all(color: AppColors.border),
      ),
      alignment: Alignment.center,
      child: Text(
        number,
        style: TextStyle(
          color: isActive ? Colors.white : AppColors.textGrey,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildStepLine() {
    return Container(
      width: 40,
      height: 1,
      color: AppColors.border,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
