import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_routes.dart';

class RegisterFooter extends StatelessWidget {
  const RegisterFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => context.go(AppRoutes.home),
        child: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 14, color: AppColors.textGrey),
            children: [
              TextSpan(text: AppStrings.hasAccount),
              TextSpan(
                text: AppStrings.loginTitle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
