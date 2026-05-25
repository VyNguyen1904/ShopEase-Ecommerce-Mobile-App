import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_routes.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Đơn hàng của tôi',
        'icon': Icons.assignment_outlined,
        'onTap': () => context.go(AppRoutes.orders),
      },
      {
        'title': 'Danh sách yêu thích',
        'icon': Icons.favorite_border,
        'onTap': () {},
      },
      {
        'title': 'Địa chỉ của tôi',
        'icon': Icons.location_on_outlined,
        'onTap': () {},
      },
      {
        'title': 'Phương thức thanh toán',
        'icon': Icons.credit_card_outlined,
        'onTap': () {},
      },
      {
        'title': 'Cài đặt',
        'icon': Icons.settings_outlined,
        'onTap': () => context.push(AppRoutes.settings),
      },
      {
        'title': 'Trung tâm hỗ trợ',
        'icon': Icons.headset_mic_outlined,
        'onTap': () {},
      },
      {
        'title': 'Đăng xuất',
        'icon': Icons.logout_outlined,
        'onTap': () => context.go(AppRoutes.splash),
        'isDestructive': true,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              // 1. Profile Header block
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&auto=format&fit=crop&q=80',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Jane Doe',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'jane.doe@gmail.com',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textGrey.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios,
                          size: 16, color: AppColors.textLight),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 2. Menu options card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(8),
                    itemCount: menuItems.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: AppColors.border,
                    ),
                    itemBuilder: (context, index) {
                      final item = menuItems[index];
                      final isDestructive = item['isDestructive'] ?? false;

                      return ListTile(
                        onTap: item['onTap'],
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDestructive
                                ? AppColors.accentLight
                                : AppColors.primaryLight.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            item['icon'],
                            color: isDestructive
                                ? AppColors.accent
                                : AppColors.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          item['title'],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDestructive
                                ? AppColors.accent
                                : AppColors.textDark,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppColors.textLight,
                          size: 18,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
