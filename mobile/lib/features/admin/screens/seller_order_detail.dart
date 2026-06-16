import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/order_provider.dart';
import '../../../core/models/order_model.dart';
import '../../../core/constants/app_strings.dart';

class SellerOrderDetail extends ConsumerStatefulWidget {
  final String orderId;

  const SellerOrderDetail({super.key, required this.orderId});

  @override
  ConsumerState<SellerOrderDetail> createState() => _SellerOrderDetailState();
}

class _SellerOrderDetailState extends ConsumerState<SellerOrderDetail> {
  int _activeStatusStep =
      0; // 0 = Confirmed, 1 = Packed, 2 = Shipped, 3 = Completed

  final List<String> _statusTexts = [
    AppStrings.processingStatus,
    AppStrings.packedStatus,
    AppStrings.shipping,
    AppStrings.completedStatus,
  ];

  String _formatCurrency(double amount) {
    return amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

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
            icon: const Icon(Icons.more_horiz, color: AppColors.textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: ref.watch(orderDetailProvider(widget.orderId)).when(
        data: (order) {
          int step = 0;
          if (order.status == OrderStatus.CONFIRMED) step = 0;
          if (order.status == OrderStatus.SHIPPING) step = 2; // Skipped Packed for now
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
                      Container(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '#${order.id.split('-').last.toUpperCase()}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: step == 0
                                        ? const Color(0xFFFFF7ED)
                                        : (step == 3
                                              ? const Color(0xFFEAF5F6)
                                              : const Color(0xFFECEFFF)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    step == -1 ? AppStrings.cancelled : _statusTexts[step],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: step == 0
                                          ? const Color(0xFFD97706)
                                          : (step == 3
                                                ? AppColors.primary
                                                : const Color(0xFF3B82F6)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${DateFormat('dd/MM/yyyy • HH:mm').format(order.createdAt)}  •  ${AppStrings.paymentMethodPrefix} ${order.paymentMethod}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                  // 2. Customer info "Thông tin khách hàng"
                  _buildSectionContainer(
                    title: AppStrings.customerInfo,
                    icon: Icons.person_outline,
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.shipRecipient,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '📞 ${order.shipPhone}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.chat_bubble_outline,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Delivery address "Địa chỉ giao hàng" (with map)
                  _buildSectionContainer(
                    title: AppStrings.shippingAddress,
                    icon: Icons.location_on_outlined,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    order.shipRecipient,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    AppStrings.defaultAddress,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${order.shipStreet}, ${order.shipDistrict}, ${order.shipCity}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textGrey,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '📞 ${order.shipPhone}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Mock map placeholder
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=200&auto=format&fit=crop&q=80',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. Products section
                  _buildSectionContainer(
                    title: AppStrings.products,
                    icon: Icons.inventory_2_outlined,
                    child: Column(
                      children: [
                        ...order.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.bgLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Image.network(
                                  item.productImage.isNotEmpty ? item.productImage : 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=200&auto=format&fit=crop&q=80',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_formatCurrency(item.unitPrice)}đ  •  x${item.quantity}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${_formatCurrency(item.subtotal)}đ',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        )),
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: AppColors.border),
                        const SizedBox(height: 12),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.shippingFee,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textGrey,
                              ),
                            ),
                            Text(
                              '30.000đ',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              AppStrings.totalAmount,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              '${_formatCurrency(order.totalAmount)}đ',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. Payment Details
                  _buildSectionContainer(
                    title: AppStrings.paymentMethod,
                    icon: Icons.credit_card_outlined,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                  // 6. Timeline history "Lịch sử đơn hàng"
                  _buildSectionContainer(
                    title: AppStrings.orderHistory,
                    icon: Icons.history,
                    child: Column(
                      children: [
                        _buildTimelineItem(
                          title: AppStrings.orderPlacedHistory,
                          time: DateFormat('dd/MM/yyyy • HH:mm').format(order.createdAt),
                          user: AppStrings.system,
                          isDone: true,
                        ),
                        _buildTimelineItem(
                          title: AppStrings.orderConfirmedMsg,
                          time: step >= 0 ? DateFormat('dd/MM/yyyy • HH:mm').format(order.createdAt) : '--:--',
                          user: step >= 0 ? AppStrings.system : '---',
                          isDone: step >= 0,
                        ),
                        _buildTimelineItem(
                          title: AppStrings.orderShippingMsg,
                          time: step >= 2 ? '--:--' : '--:--/--/----  •  --:--',
                          user: step >= 2 ? AppStrings.you : '---',
                          isDone: step >= 2,
                        ),
                        _buildTimelineItem(
                          title: AppStrings.orderDeliveredMsg,
                          time: step >= 3 ? '--:--' : '--:--/--/----  •  --:--',
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

          if (order.status != OrderStatus.CANCELLED && order.status != OrderStatus.DELIVERED)
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
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              await ref.read(orderServiceProvider).markAsDelivered(order.id);
                              ref.invalidate(orderDetailProvider(order.id));
                              ref.invalidate(sellerOrdersProvider);
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
                          child: const Text(AppStrings.confirmDelivered, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
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
    ));
  }

  Widget _buildSectionContainer({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
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

  Widget _buildTimelineItem({
    required String title,
    required String time,
    required String user,
    required bool isDone,
    bool isLast = false,
  }) {
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

  // _buildActionButton removed
}
