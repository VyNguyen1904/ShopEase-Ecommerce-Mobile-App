import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/order_provider.dart';
import '../../../core/models/order_model.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/notification_provider.dart';
import '../widgets/seller_order_detail_widgets.dart';
import '../widgets/seller_order_header.dart';
import '../widgets/seller_order_customer_info.dart';
import '../widgets/seller_order_items_list.dart';

class SellerOrderDetail extends ConsumerStatefulWidget {
  final String orderId;

  const SellerOrderDetail({super.key, required this.orderId});

  @override
  ConsumerState<SellerOrderDetail> createState() => _SellerOrderDetailState();
}

class _SellerOrderDetailState extends ConsumerState<SellerOrderDetail> {
  final List<String> _statusTexts = [
    AppStrings.processingStatus,
    AppStrings.packedStatus,
    AppStrings.shipping,
    AppStrings.completedStatus,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          AppStrings.orderDetail,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textDark),
            tooltip: 'Làm mới',
            onPressed: () =>
                ref.invalidate(orderDetailProvider(widget.orderId)),
          ),
        ],
      ),
      body: ref
          .watch(orderDetailProvider(widget.orderId))
          .when(
            data: (order) {
              // Watch notifications so this screen auto-rebuilds on order status changes
              ref.watch(notificationListProvider);
              int step = 0;
              if (order.status == OrderStatus.PENDING) step = -2;
              if (order.status == OrderStatus.CONFIRMED) step = 0;
              if (order.status == OrderStatus.PACKED) step = 1;
              if (order.status == OrderStatus.SHIPPED) step = 2;
              if (order.status == OrderStatus.DELIVERED) step = 3;
              if (order.status == OrderStatus.CANCELLED) step = -1;

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Order Code block
                          SellerOrderHeader(
                            order: order,
                            step: step,
                            statusTexts: _statusTexts,
                          ),
                          const SizedBox(height: 16),

                          // 2. Customer info & Delivery address
                          SellerOrderCustomerInfo(order: order),
                          const SizedBox(height: 16),

                          // 3. Products section
                          SellerOrderItemsList(order: order),
                          const SizedBox(height: 16),

                          // 4. Payment Details
                          SellerSectionContainer(
                            title: AppStrings.paymentMethod,
                            icon: Icons.credit_card_outlined,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      AppStrings.method,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                    Text(
                                      order.paymentMethod,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textDark,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 6. Timeline history
                          SellerSectionContainer(
                            title: AppStrings.orderHistory,
                            icon: Icons.history,
                            child: Column(
                              children: [
                                SellerTimelineItem(
                                  title: AppStrings.orderPlacedHistory,
                                  time: DateFormat(
                                    'dd/MM/yyyy • HH:mm',
                                  ).format(order.createdAt),
                                  user: AppStrings.system,
                                  isDone: true,
                                ),
                                SellerTimelineItem(
                                  title: AppStrings.orderConfirmedMsg,
                                  time: step >= 0
                                      ? DateFormat(
                                          'dd/MM/yyyy • HH:mm',
                                        ).format(order.createdAt)
                                      : '--:--',
                                  user: step >= 0 ? AppStrings.you : '---',
                                  isDone: step >= 0,
                                ),
                                SellerTimelineItem(
                                  title: AppStrings.packedStatus,
                                  time: step >= 1 ? '--:--' : '--:--',
                                  user: step >= 1 ? AppStrings.you : '---',
                                  isDone: step >= 1,
                                ),
                                SellerTimelineItem(
                                  title: AppStrings.orderShippingMsg,
                                  time: step >= 2
                                      ? '--:--'
                                      : '--:--/--/----  •  --:--',
                                  user: step >= 2 ? AppStrings.you : '---',
                                  isDone: step >= 2,
                                ),
                                SellerTimelineItem(
                                  title: AppStrings.orderDeliveredMsg,
                                  time: step >= 3
                                      ? '--:--'
                                      : '--:--/--/----  •  --:--',
                                  user: step >= 3 ? AppStrings.system : '---',
                                  isDone: step >= 3,
                                  isLast: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  if (order.status != OrderStatus.CANCELLED &&
                      order.status != OrderStatus.DELIVERED)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            AppStrings.updateOrderStatus,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textGrey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              if (order.status == OrderStatus.PENDING)
                                SellerActionButton(
                                  orderId: order.id,
                                  label: AppStrings.confirm,
                                  action: () => ref
                                      .read(orderServiceProvider)
                                      .confirmOrder(order.id),
                                ),
                              if (order.status == OrderStatus.CONFIRMED)
                                SellerActionButton(
                                  orderId: order.id,
                                  label: AppStrings.packedStatus,
                                  action: () => ref
                                      .read(orderServiceProvider)
                                      .packOrder(order.id),
                                ),
                              if (order.status == OrderStatus.PACKED)
                                SellerActionButton(
                                  orderId: order.id,
                                  label: 'Giao vận chuyển',
                                  action: () => ref
                                      .read(orderServiceProvider)
                                      .shipOrder(order.id),
                                ),
                              if (order.status == OrderStatus.SHIPPED)
                                SellerActionButton(
                                  orderId: order.id,
                                  label: AppStrings.confirmDelivered,
                                  action: () => ref
                                      .read(orderServiceProvider)
                                      .markAsDelivered(order.id),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('${AppStrings.errorPrefix}$e')),
          ),
    );
  }
}
