import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/providers/auth_provider.dart';
import '../widgets/account_section_title.dart';
import '../widgets/account_menu_group.dart';
import '../widgets/account_menu_item.dart';
import '../widgets/account_user_info_card.dart';
import '../widgets/account_unauthenticated_view.dart';
import '../widgets/account_error_view.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Slightly off-white bg
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          AppStrings.navProfile,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Card
            userProfileAsync.when(
              data: (user) {
                if (user == null) {
                  return const AccountUnauthenticatedView();
                }
                return AccountUserInfoCard(user: user);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => AccountErrorView(error: err),
            ),
            const SizedBox(height: 32),

            // Account Section
            const AccountSectionTitle(title: AppStrings.accountSection),
            const SizedBox(height: 12),
            AccountMenuGroup(
              children: [
                AccountMenuItem(
                  icon: Icons.person_outline,
                  title: AppStrings.personalInfo,
                  onTap: () => context.push(AppRoutes.profileEdit),
                ),
                AccountMenuItem(
                  icon: Icons.location_on_outlined,
                  title: AppStrings.addressBook,
                  onTap: () => context.push(AppRoutes.address),
                ),
                const AccountMenuItem(
                  icon: Icons.lock_outline,
                  title: AppStrings.passwordSecurity,
                ),
                AccountMenuItem(
                  icon: Icons.notifications_none,
                  title: AppStrings.notificationSettings,
                  onTap: () => context.push(AppRoutes.notificationSettings),
                ),
                const AccountMenuItem(
                  icon: Icons.language,
                  title: AppStrings.language,
                  trailingText: AppStrings.vietnamese,
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Preferences Section
            const AccountSectionTitle(title: AppStrings.preferencesSection),
            const SizedBox(height: 12),
            AccountMenuGroup(
              children: [
                AccountMenuItem(
                  icon: Icons.settings_outlined,
                  title: AppStrings.settings,
                  onTap: () => context.push(AppRoutes.settings),
                ),
                const AccountMenuItem(
                  icon: Icons.feed_outlined,
                  title: AppStrings.aboutUs,
                ),
                const AccountMenuItem(
                  icon: Icons.contrast,
                  title: AppStrings.theme,
                  trailingText: AppStrings.lightTheme,
                ),
                AccountMenuItem(
                  icon: Icons.favorite_border,
                  title: AppStrings.wishlist,
                  onTap: () => context.push(AppRoutes.wishlist),
                ),
                AccountMenuItem(
                  icon: Icons.assignment_outlined,
                  title: AppStrings.myOrders,
                  onTap: () => context.go(AppRoutes.orders),
                ),
                AccountMenuItem(
                  icon: Icons.rate_review_outlined,
                  title: AppStrings.myReviews,
                  onTap: () => context.push(AppRoutes.myReviews),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Support Section
            const AccountSectionTitle(title: AppStrings.supportSection),
            const SizedBox(height: 12),
            AccountMenuGroup(
              children: [
                AccountMenuItem(
                  icon: Icons.map_outlined,
                  title: AppStrings.storeMap,
                  onTap: () => context.push(AppRoutes.storeMap),
                ),
                const AccountMenuItem(
                  icon: Icons.help_outline,
                  title: AppStrings.helpCenter,
                ),
                AccountMenuItem(
                  icon: Icons.logout_outlined,
                  title: AppStrings.logout,
                  isDestructive: true,
                  onTap: () async {
                    await ref.read(authServiceProvider).logout();
                    if (!context.mounted) return;
                    ref.invalidate(userProfileProvider);
                    context.go(AppRoutes.splash);
                  },
                ),
              ],
            ),

            // Padding to account for the floating bottom nav bar
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
