import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers/auth_provider.dart';

class SellerDashboardHeader extends ConsumerWidget {
  const SellerDashboardHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final userName = userAsync.maybeWhen(
      data: (user) => user?.fullName.split(' ').last ?? 'Seller',
      orElse: () => 'Seller',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              '${AppStrings.helloPrefix}$userName',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          AppStrings.shopOverviewDesc,
          style: TextStyle(fontSize: 14, color: AppColors.textGrey),
        ),
      ],
    );
  }
}
