import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/notification_item.dart';
import '../../../core/router/app_routes.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _activeTab = 'Tất cả';

  final List<String> _tabs = [
    'Tất cả',
    'Đơn hàng',
    'Khuyến mãi',
    'Voucher',
    'Tin nhắn',
    'Hệ thống',
  ];

  NotificationType? _getTypeFromTab(String tab) {
    switch (tab) {
      case 'Đơn hàng':
        return NotificationType.order;
      case 'Khuyến mãi':
        return NotificationType.promotion;
      case 'Voucher':
        return NotificationType.voucher;
      case 'Tin nhắn':
        return NotificationType.message;
      case 'Hệ thống':
        return NotificationType.system;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filterType = _getTypeFromTab(_activeTab);
    final filteredNotifications = filterType == null
        ? mockNotifications
        : mockNotifications.where((n) => n.type == filterType).toList();

    final Map<String, List<NotificationItem>> groupedNotifications = {};
    for (var n in filteredNotifications) {
      if (!groupedNotifications.containsKey(n.group)) {
        groupedNotifications[n.group] = [];
      }
      groupedNotifications[n.group]!.add(n);
    }

    final sortedGroups = ['Hôm nay', 'Hôm qua', 'Trước đó']
        .where((g) => groupedNotifications.containsKey(g))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Thông báo',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textDark, size: 24),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Horizontal tabs
          Container(
            height: 48,
            padding: const EdgeInsets.only(left: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                final tab = _tabs[index];
                final isSelected = _activeTab == tab;
                int? badgeCount;
                if (tab == 'Tất cả') {
                  badgeCount =
                      mockNotifications.where((n) => n.isUnread).length;
                }

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeTab = tab;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          tab,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textGrey,
                          ),
                        ),
                        if (badgeCount != null && badgeCount > 0) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: AppColors.alertRed,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$badgeCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // 2. Notifications list
          Expanded(
            child: filteredNotifications.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none,
                            size: 64, color: AppColors.textLight),
                        SizedBox(height: 12),
                        Text(
                          'Không có thông báo nào',
                          style: TextStyle(
                              color: AppColors.textGrey, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: sortedGroups.length,
                    itemBuilder: (context, groupIndex) {
                      final groupName = sortedGroups[groupIndex];
                      final items = groupedNotifications[groupName]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 4.0),
                            child: Text(
                              groupName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          ...items.map((item) =>
                              _buildNotificationTile(context, item)),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(
      BuildContext context, NotificationItem item) {
    Color iconBgColor;
    Color iconColor;
    IconData icon;

    switch (item.type) {
      case NotificationType.order:
        iconBgColor = const Color(0xFFE6F5F6);
        iconColor = AppColors.primary;
        icon = item.title.contains('vận chuyển')
            ? Icons.local_shipping_outlined
            : Icons.inventory_2_outlined;
        break;
      case NotificationType.promotion:
        iconBgColor = const Color(0xFFFFECE5);
        iconColor = AppColors.accent;
        icon = Icons.local_offer_outlined;
        break;
      case NotificationType.voucher:
        iconBgColor = const Color(0xFFFFF7ED);
        iconColor = const Color(0xFFD97706);
        icon = Icons.confirmation_number_outlined;
        break;
      case NotificationType.message:
        iconBgColor = const Color(0xFFF5F3FF);
        iconColor = const Color(0xFF7C3AED);
        icon = Icons.chat_bubble_outline;
        break;
      case NotificationType.system:
        iconBgColor = const Color(0xFFECFEFF);
        iconColor = const Color(0xFF0891B2);
        icon = item.title.contains('mừng')
            ? Icons.celebration_outlined
            : Icons.notifications_active_outlined;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (item.type == NotificationType.message) {
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
                                fontWeight: item.isUnread
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          Text(
                            item.time,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.content,
                        style: TextStyle(
                          fontSize: 13,
                          color: item.isUnread
                              ? AppColors.textDark
                              : AppColors.textGrey,
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
                  child: item.isUnread
                      ? Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.alertRed,
                            shape: BoxShape.circle,
                          ),
                        )
                      : const Icon(
                          Icons.chevron_right,
                          color: AppColors.textLight,
                          size: 18,
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
