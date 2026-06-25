import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/order_model.dart';
import '../../../core/providers/order_provider.dart';
import '../../../core/router/app_routes.dart';
import '../../cart/providers/cart_provider.dart';
import 'order_item_row.dart';

class OrderCard extends ConsumerWidget {
  final OrderResponse order;
  final String statusStr;
  final Color statusColor;

  const OrderCard({
    super.key,
    required this.order,
    required this.statusStr,
    required this.statusColor,
  });

  String _formatCurrency(double amount) {
    return amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.orderDetailPath(order.id)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 6),
            Text(
              DateFormat('dd MMM, yyyy').format(order.createdAt),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppColors.border),
            ),
            ...order.items.map((item) => OrderItemRow(
                  item: item,
                  formatCurrency: _formatCurrency,
                )),
            const Padding(
              padding: EdgeInsets.only(top: 4, bottom: 12),
              child: Divider(height: 1, color: AppColors.border),
            ),
            _buildFooter(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '${AppStrings.orderCodePrefix} ${order.id.split('-').last.toUpperCase()}',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            statusStr,
            style: TextStyle(
              fontSize: 12,
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${order.items.length} ${AppStrings.itemCount}',
          style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
        ),
        Row(
          children: [
            const Text(
              AppStrings.totalPrice,
              style: TextStyle(fontSize: 13, color: AppColors.textDark),
            ),
            Text(
              '${_formatCurrency(order.totalAmount)} đ',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Extracted action buttons row – kept separate for readability
class OrderCardActions extends ConsumerWidget {
  final OrderResponse order;
  final String statusStr;

  const OrderCardActions({
    super.key,
    required this.order,
    required this.statusStr,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.end,
        children: [
          if (statusStr == AppStrings.pending) _buildCancelButton(context, ref),
          if (statusStr == AppStrings.delivered || statusStr == AppStrings.completedStatus) ...[
            _buildReturnRefundButton(context),
            _buildReviewButton(context),
          ],
          _buildPrimaryButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context, WidgetRef ref) {
    return OutlinedButton(
      onPressed: () => _handleCancel(context, ref),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.alertRed),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: const Text(
        AppStrings.cancelAction,
        style: TextStyle(color: AppColors.alertRed, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildReviewButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        context.push(AppRoutes.review, extra: {'order': order});
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: const Text(
        AppStrings.reviewAction,
        style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildReturnRefundButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () => _handleReturnRefund(context),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.textGrey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: const Text(
        AppStrings.returnRefundAction,
        style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _handleReturnRefund(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.returnRefundAction, style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(AppStrings.returnRefundPrompt),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.no, style: TextStyle(color: AppColors.textGrey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(AppStrings.returnRefundSuccess)),
              );
            },
            child: const Text(AppStrings.yes, style: TextStyle(color: AppColors.primaryDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context, WidgetRef ref) {
    final isDeliveredOrCompleted = statusStr == AppStrings.delivered || statusStr == AppStrings.completedStatus;
    return ElevatedButton(
      onPressed: () => isDeliveredOrCompleted
          ? _handleReorder(context, ref)
          : _handleTrack(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDeliveredOrCompleted ? AppColors.textDark : AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(
        isDeliveredOrCompleted ? AppStrings.reorderAction : AppStrings.trackAction,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Future<void> _handleCancel(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          AppStrings.cancelOrder,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(AppStrings.cancelPrompt),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              AppStrings.no,
              style: TextStyle(color: AppColors.textGrey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              AppStrings.cancelAction,
              style: TextStyle(color: AppColors.alertRed),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final rootNav = Navigator.of(context, rootNavigator: true);
      final messenger = ScaffoldMessenger.of(context);
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
        await ref.read(orderServiceProvider).cancelOrder(order.id);
        rootNav.pop();
        ref.invalidate(userOrdersProvider);
        messenger.showSnackBar(
          const SnackBar(content: Text(AppStrings.cancelOrderSuccess)),
        );
      } catch (e) {
        rootNav.pop();
        messenger.showSnackBar(
          SnackBar(content: Text('${AppStrings.errorPrefix}$e')),
        );
      }
    }
  }

  Future<void> _handleReorder(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      for (final item in order.items) {
        await ref.read(cartProvider.notifier).addToCart(
              item.productId,
              item.quantity,
              color: item.color,
              size: item.size,
            );
      }
      if (context.mounted) {
        Navigator.pop(context);
        context.push(AppRoutes.cart);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  void _handleTrack(BuildContext context) {
    context.push(AppRoutes.orderDetailPath(order.id));
  }
}
