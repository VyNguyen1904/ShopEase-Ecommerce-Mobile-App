import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/providers/notification_provider.dart';
import '../models/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  String _activeTab = AppStrings.all;

  final List<String> _tabs = [
    AppStrings.all,
    AppStrings.orders,
    AppStrings.promotions,
    AppStrings.vouchers,
    AppStrings.messages,
    AppStrings.system,
  ];

  String? _getTypeFromTab(String tab) {
    switch (tab) {
      case AppStrings.orders:
        return 'ORDER_UPDATE';
      case AppStrings.promotions:
        return 'PROMOTION';
      case AppStrings.vouchers:
        return 'VOUCHER';
      case AppStrings.messages:
        return 'MESSAGE';
      case AppStrings.system:
        return 'SYSTEM';
      default:
        return null;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(time);
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else {
      return DateFormat('dd/MM/yyyy').format(time);
    }
  }

  String _getGroup(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inDays == 0 && now.day == time.day) {
      return AppStrings.today;
    } else if (difference.inDays <= 1 && (now.day - time.day).abs() == 1) {
      return AppStrings.yesterday;
    } else {
      return AppStrings.earlier;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          AppStrings.notifications,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: AppColors.textDark, size: 24),
            onPressed: () {
              ref.read(notificationListProvider.notifier).markAllAsRead();
            },
            tooltip: 'Đánh dấu đã đọc tất cả',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Horizontal tabs
          Container(
            height: 48,
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _tabs.map((tab) {
                    final isSelected = _activeTab == tab;
                    return GestureDetector(
                      onTap: () => setState(() => _activeTab = tab),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                        ),
                        child: Text(
                          tab,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? AppColors.primary : AppColors.textGrey,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // Notifications list
          Expanded(
            child: notificationsAsync.when(
              data: (notifications) {
                final filterType = _getTypeFromTab(_activeTab);
                final filteredNotifications = filterType == null
                    ? notifications
                    : notifications.where((n) => n.type == filterType).toList();

                if (filteredNotifications.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none, size: 64, color: AppColors.textLight),
                        SizedBox(height: 12),
                        Text(
                          AppStrings.noNotifications,
                          style: TextStyle(color: AppColors.textGrey, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                final Map<String, List<NotificationModel>> groupedNotifications = {};
                for (var n in filteredNotifications) {
                  final group = _getGroup(n.createdAt);
                  if (!groupedNotifications.containsKey(group)) {
                    groupedNotifications[group] = [];
                  }
                  groupedNotifications[group]!.add(n);
                }

                final sortedGroups = [AppStrings.today, AppStrings.yesterday, AppStrings.earlier]
                    .where((g) => groupedNotifications.containsKey(g))
                    .toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: sortedGroups.length,
                  itemBuilder: (context, groupIndex) {
                    final groupName = sortedGroups[groupIndex];
                    final items = groupedNotifications[groupName]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
                          child: Text(
                            groupName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        ...items.map((item) => _buildNotificationTile(context, item)),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Lỗi: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, NotificationModel item) {
    Color iconBgColor;
    Color iconColor;
    IconData icon;

    switch (item.type) {
      case 'ORDER_UPDATE':
        iconBgColor = const Color(0xFFE6F5F6);
        iconColor = AppColors.primary;
        icon = item.title.toLowerCase().contains('giao')
            ? Icons.local_shipping_outlined
            : Icons.inventory_2_outlined;
        break;
      case 'PROMOTION':
        iconBgColor = const Color(0xFFFFECE5);
        iconColor = AppColors.accent;
        icon = Icons.local_offer_outlined;
        break;
      case 'VOUCHER':
        iconBgColor = const Color(0xFFFFF7ED);
        iconColor = const Color(0xFFD97706);
        icon = Icons.confirmation_number_outlined;
        break;
      case 'MESSAGE':
        iconBgColor = const Color(0xFFF5F3FF);
        iconColor = const Color(0xFF7C3AED);
        icon = Icons.chat_bubble_outline;
        break;
      default:
        iconBgColor = const Color(0xFFECFEFF);
        iconColor = const Color(0xFF0891B2);
        icon = Icons.notifications_active_outlined;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: item.isRead ? Colors.white : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!item.isRead) {
              ref.read(notificationListProvider.notifier).markAsRead(item.id);
            }
            if (item.type == 'MESSAGE') {
              context.push(AppRoutes.chats);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          Text(
                            _formatTime(item.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.message,
                        style: TextStyle(
                          fontSize: 13,
                          color: item.isRead ? AppColors.textGrey : AppColors.textDark,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 48,
                  alignment: Alignment.center,
                  child: item.isRead
                      ? const Icon(Icons.chevron_right, color: AppColors.textLight, size: 18)
                      : Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.alertRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
