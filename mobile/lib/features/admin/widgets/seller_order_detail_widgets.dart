import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/order_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/models/notification_model.dart';

class SellerSectionContainer extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const SellerSectionContainer({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class SellerTimelineItem extends StatelessWidget {
  final String title;
  final String time;
  final String user;
  final bool isDone;
  final bool isLast;

  const SellerTimelineItem({
    super.key,
    required this.title,
    required this.time,
    required this.user,
    required this.isDone,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dots and lines
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: isDone ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone ? AppColors.primary : AppColors.textLight,
                  width: 2.5,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2.5,
                height: 38,
                color: isDone ? AppColors.primary : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Timeline content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDone ? AppColors.textDark : AppColors.textLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
        Text(
          user,
          style: TextStyle(
            fontSize: 12,
            color: isDone ? AppColors.textGrey : AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class SellerActionButton extends ConsumerWidget {
  final String orderId;
  final String label;
  final Future<dynamic> Function() action;

  const SellerActionButton({
    super.key,
    required this.orderId,
    required this.label,
    required this.action,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () async {
          try {
            await action();
            ref.invalidate(orderDetailProvider(orderId));
            ref.invalidate(sellerOrdersProvider);
            // Instead of invalidating which might just reload empty list from backend, we add locally for immediate UI feedback.
            ref.read(notificationListProvider.notifier).addLocalNotification(
              NotificationModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: 'Cập nhật đơn hàng',
                message: 'Trạng thái đơn hàng #${orderId.split('-').last.toUpperCase()} đã được cập nhật thành "$label".',
                type: 'ORDER_UPDATE',
                isRead: false,
                createdAt: DateTime.now(),
              )
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Cập nhật trạng thái thành công'),
                backgroundColor: AppColors.primary,
              ));
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${AppStrings.errorPrefix}$e')));
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
