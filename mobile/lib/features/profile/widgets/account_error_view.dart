import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/providers/auth_provider.dart';

class AccountErrorView extends ConsumerWidget {
  final Object error;

  const AccountErrorView({super.key, required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('unauthorized') || errorStr.contains('đăng nhập')) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 48,
                color: AppColors.textGrey,
              ),
              const SizedBox(height: 16),
              const Text(
                AppStrings.sessionExpired,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                AppStrings.loginAgainPrompt,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGrey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(authServiceProvider).logout();
                  context.go(AppRoutes.login);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text(AppStrings.loginAgain),
              ),
            ],
          ),
        ),
      );
    }

    return Center(child: Text('${AppStrings.errorPrefix}$error'));
  }
}
