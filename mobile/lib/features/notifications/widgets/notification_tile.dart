import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../core/models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel item;
  final String formattedTime;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.item,
    required this.formattedTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
          onTap: onTap,
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
                                fontWeight: item.isRead
                                    ? FontWeight.w600
                                    : FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          Text(
                            formattedTime,
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
                          color: item.isRead
                              ? AppColors.textGrey
                              : AppColors.textDark,
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
                      ? const Icon(
                          Icons.chevron_right,
                          color: AppColors.textLight,
                          size: 18,
                        )
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
