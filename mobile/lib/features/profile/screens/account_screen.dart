import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_routes.dart';
import '../../auth/providers/auth_provider.dart';

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
          'Cá nhân',
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
              data: (user) => Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundImage:
                          user.avatar != null && user.avatar!.isNotEmpty
                          ? NetworkImage(user.avatar!)
                          : const NetworkImage(
                              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&auto=format&fit=crop&q=80',
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textGrey.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Lỗi: $err')),
            ),
            const SizedBox(height: 32),

            // Account Section
            _buildSectionTitle('Tài khoản'),
            const SizedBox(height: 12),
            _buildMenuGroup([
              _buildMenuItem(
                icon: Icons.person_outline,
                title: 'Quản lý thông tin',
                onTap: () => context.push(AppRoutes.address),
              ),
              _buildMenuItem(
                icon: Icons.lock_outline,
                title: 'Mật khẩu & Bảo mật',
              ),
              _buildMenuItem(
                icon: Icons.notifications_none,
                title: 'Cài đặt thông báo',
              ),
              _buildMenuItem(
                icon: Icons.language,
                title: 'Ngôn ngữ',
                trailingText: 'Tiếng Việt',
              ),
            ]),
            const SizedBox(height: 28),

            // Preferences Section
            _buildSectionTitle('Tùy chọn'),
            const SizedBox(height: 12),
            _buildMenuGroup([
              _buildMenuItem(
                icon: Icons.settings_outlined,
                title: 'Cài đặt',
                onTap: () => context.push(AppRoutes.settings),
              ),
              _buildMenuItem(icon: Icons.feed_outlined, title: 'Về chúng tôi'),
              _buildMenuItem(
                icon: Icons.contrast,
                title: 'Giao diện',
                trailingText: 'Sáng',
              ),
              _buildMenuItem(
                icon: Icons.assignment_outlined,
                title: 'Đơn hàng của tôi',
                onTap: () => context.go(AppRoutes.orders),
              ),
            ]),
            const SizedBox(height: 28),

            // Support Section
            _buildSectionTitle('Hỗ trợ'),
            const SizedBox(height: 12),
            _buildMenuGroup([
              _buildMenuItem(
                icon: Icons.help_outline,
                title: 'Trung tâm trợ giúp',
              ),
              _buildMenuItem(
                icon: Icons.logout_outlined,
                title: 'Đăng xuất',
                isDestructive: true,
                onTap: () async {
                  await ref.read(authServiceProvider).logout();
                  ref.invalidate(userProfileProvider);
                  if (context.mounted) context.go(AppRoutes.splash);
                },
              ),
            ]),

            // Padding to account for the floating bottom nav bar
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.textGrey,
      ),
    );
  }

  Widget _buildMenuGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final int index = entry.key;
          final Widget item = entry.value;
          if (index != children.length - 1) {
            return Column(
              children: [
                item,
                const Divider(
                  height: 1,
                  indent: 56,
                  endIndent: 20,
                  color: AppColors.border,
                ),
              ],
            );
          }
          return item;
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? trailingText,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap ?? () {},
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.accent : AppColors.textDark,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDestructive ? AppColors.accent : AppColors.textDark,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) ...[
            Text(
              trailingText,
              style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
            ),
            const SizedBox(width: 8),
          ],
          const Icon(Icons.chevron_right, color: AppColors.textLight, size: 20),
        ],
      ),
    );
  }
}
