import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/providers/notification_provider.dart';
import 'home_icon_button.dart';

class HomeSearchHeader extends ConsumerWidget {
  const HomeSearchHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.push(AppRoutes.search),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: AppColors.textLight, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppStrings.searchHomeHint,
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ref
              .watch(unreadNotificationCountProvider)
              .when(
                data: (count) => HomeIconButton(
                  icon: Icons.notifications_outlined,
                  onTap: () => context.push(AppRoutes.notifications),
                  showBadge: count > 0,
                ),
                loading: () => HomeIconButton(
                  icon: Icons.notifications_outlined,
                  onTap: () => context.push(AppRoutes.notifications),
                  showBadge: false,
                ),
                error: (_, __) => HomeIconButton(
                  icon: Icons.notifications_outlined,
                  onTap: () => context.push(AppRoutes.notifications),
                  showBadge: false,
                ),
              ),
          const SizedBox(width: 10),
          HomeIconButton(
            icon: Icons.chat_bubble_outline,
            onTap: () => context.push(AppRoutes.chats),
            showBadge: false,
          ),
          const SizedBox(width: 10),
          HomeIconButton(icon: Icons.qr_code_scanner, onTap: () {}),
        ],
      ),
    );
  }
}
