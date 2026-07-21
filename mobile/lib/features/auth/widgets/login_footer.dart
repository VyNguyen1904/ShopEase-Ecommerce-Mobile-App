import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_routes.dart';

class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.register),
        child: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 14, color: AppColors.textGrey),
            children: [
              TextSpan(text: AppStrings.noAccount),
              TextSpan(
                text: AppStrings.registerNow,
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
