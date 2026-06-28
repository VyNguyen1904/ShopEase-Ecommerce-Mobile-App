import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/providers/order_provider.dart';
import '../../../../core/models/order_model.dart';

class OrderBottomActions extends ConsumerWidget {
  final OrderResponse order;

  const OrderBottomActions({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom
            : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (order.status == OrderStatus.PENDING) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () => _handleCancelOrder(context, ref),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.alertRed),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  AppStrings.cancelOrder,
                  style: TextStyle(
                    color: AppColors.alertRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          if (order.status == OrderStatus.SHIPPED) ...[
            Expanded(
              child: ElevatedButton(
                onPressed: () => _handleConfirmDelivery(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Đã nhận được hàng',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          if (order.status == OrderStatus.DELIVERED) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () => _handleReturnRefund(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.textGrey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  AppStrings.returnRefundAction,
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  context.push(AppRoutes.review, extra: {'order': order});
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  AppStrings.reviewAction,
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      AppStrings.shopMore,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
        ],
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

  void _handleConfirmDelivery(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận đã nhận hàng', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Bạn xác nhận đã nhận được hàng và hàng hóa trong tình trạng tốt?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.no, style: TextStyle(color: AppColors.textGrey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );

              try {
                await ref.read(orderServiceProvider).markAsDelivered(order.id);
                ref.invalidate(orderDetailProvider(order.id));
                ref.invalidate(userOrdersProvider);

                if (context.mounted) {
                  Navigator.pop(context); // close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cảm ơn bạn đã mua sắm! Bạn có thể đánh giá sản phẩm ngay bây giờ.')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // close loading
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${AppStrings.errorPrefix}$e')));
                }
              }
            },
            child: const Text(AppStrings.yes, style: TextStyle(color: AppColors.primaryDark)),
          ),
        ],
      ),
    );
  }

  void _handleCancelOrder(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.cancelConfirmation),
        content: const Text(AppStrings.cancelPrompt),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.no, style: TextStyle(color: AppColors.textGrey)),
          ),
          TextButton(
            onPressed: () async {
              final shouldCancel = await showDialog<bool>(
                context: context,
                builder: (dCtx) => AlertDialog(
                  title: const Text(AppStrings.cancelConfirmation),
                  content: const Text(AppStrings.cancelPrompt),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text(AppStrings.no)),
                    TextButton(onPressed: () => Navigator.pop(dCtx, true), child: const Text(AppStrings.yes, style: TextStyle(color: AppColors.alertRed))),
                  ],
                ),
              ) ?? false;

              if (!shouldCancel) return;

              if (ctx.mounted) Navigator.pop(ctx);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );

              try {
                await ref.read(orderServiceProvider).cancelOrder(order.id);
                ref.invalidate(orderDetailProvider(order.id));
                ref.invalidate(userOrdersProvider);

                if (context.mounted) {
                  Navigator.pop(context); // close loading

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (successCtx) => AlertDialog(
                      title: const Text(AppStrings.success, style: TextStyle(color: AppColors.primaryDark)),
                      content: const Text(AppStrings.cancelSuccessMsg),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(successCtx);
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(AppRoutes.home);
                            }
                          },
                          child: const Text(AppStrings.close),
                        ),
                      ],
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // close loading
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${AppStrings.errorPrefix}$e')));
                }
              }
            },
            child: const Text(AppStrings.yes, style: TextStyle(color: AppColors.alertRed)),
          ),
        ],
      ),
    );
  }
}
