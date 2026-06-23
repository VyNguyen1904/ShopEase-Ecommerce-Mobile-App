import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/order_provider.dart';
import '../../../core/models/order_model.dart';
import '../widgets/order_bottom_actions.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  String _mapStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.PENDING:
        return AppStrings.pending;
      case OrderStatus.CONFIRMED:
        return AppStrings.pending;
      case OrderStatus.SHIPPING:
        return AppStrings.shipping;
      case OrderStatus.DELIVERED:
        return AppStrings.delivered;
      case OrderStatus.CANCELLED:
        return AppStrings.cancelled;
    }
  }

  String _formatCurrency(double amount) {
    return amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textDark,
            size: 20,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: const Text(
          'Chi tiết đơn hàng',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: orderAsync.when(
        data: (order) {
          final isDelivered = order.status == OrderStatus.DELIVERED;
          return SingleChildScrollView(
            padding: const EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: 120, // space for bottom buttons
            ),
            child: Column(
              children: [
                if (isDelivered) ...[
                  // Graphic header
                  Image.asset(
                    'assets/images/order_success_graphic.png',
                    height: 180,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 100,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    AppStrings.receiveSuccess,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.thankYouShopping,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                ],
                _buildOrderInfoCard(order),
                const SizedBox(height: 16),
                _buildTimelineCard(order),
                const SizedBox(height: 16),
                _buildAddressCard(order),
                const SizedBox(height: 16),
                _buildProductsCard(order),
                const SizedBox(height: 16),
                _buildPaymentCard(order),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${AppStrings.errorPrefix}$e')),
      ),
      bottomSheet: orderAsync.hasValue ? OrderBottomActions(order: orderAsync.value!) : null,
    );
  }

  Widget _buildOrderInfoCard(OrderResponse order) {
    return _buildCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.orderCode,
                  style: TextStyle(fontSize: 13, color: AppColors.textGrey),
                ),
                Text(
                  '#${order.id.split('-').last.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: AppColors.textGrey.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${AppStrings.orderedAt} ${DateFormat('dd MMM yyyy • hh:mm a').format(order.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _mapStatus(order.status),
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(OrderResponse order) {
    bool isConfirmed = order.status == OrderStatus.CONFIRMED || order.status == OrderStatus.SHIPPING || order.status == OrderStatus.DELIVERED;
    bool isShipping = order.status == OrderStatus.SHIPPING || order.status == OrderStatus.DELIVERED;
    bool isDelivered = order.status == OrderStatus.DELIVERED;

    return _buildCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTimelineStep(
            AppStrings.orderPlaced,
            DateFormat('dd/MM, HH:mm').format(order.createdAt),
            Icons.shopping_bag_outlined,
            true,
            true,
          ),
          _buildTimelineLine(isConfirmed),
          _buildTimelineStep(
            AppStrings.processing,
            '',
            Icons.inventory_2_outlined,
            isConfirmed,
            true,
          ),
          _buildTimelineLine(isShipping),
          _buildTimelineStep(
            AppStrings.shipping,
            '',
            Icons.local_shipping_outlined,
            isShipping,
            true,
          ),
          _buildTimelineLine(isDelivered),
          _buildTimelineStep(
            AppStrings.received,
            '',
            Icons.check,
            isDelivered,
            false,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(
    String title,
    String subtitle,
    IconData icon,
    bool isCompleted,
    bool hasCheck, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.primaryDark
                    : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isCompleted ? Colors.white : Colors.grey.shade400,
                size: 20,
              ),
            ),
            if (hasCheck && isCompleted)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primaryDark,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isLast ? FontWeight.bold : FontWeight.w500,
            color: isLast ? AppColors.primaryDark : AppColors.textDark,
          ),
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
          ),
      ],
    );
  }

  Widget _buildTimelineLine(bool isCompleted) {
    return Expanded(
      child: Container(
        height: 2,
        color: isCompleted ? AppColors.primaryDark : Colors.grey.shade300,
        margin: const EdgeInsets.only(bottom: 24),
      ),
    );
  }

  Widget _buildAddressCard(OrderResponse order) {
    return _buildCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: AppColors.primaryDark,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.shippingAddress,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.textGrey),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        order.shipRecipient,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.phone, size: 12, color: AppColors.accent),
                    const SizedBox(width: 4),
                    Text(
                      order.shipPhone,
                      style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${order.shipStreet}, ${order.shipDistrict}, ${order.shipCity}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsCard(OrderResponse order) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppStrings.products} (${order.items.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...order.items.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      p.productImage.isNotEmpty ? p.productImage : 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatCurrency(p.unitPrice)}đ',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'x${p.quantity}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Text(
                    '${_formatCurrency(p.subtotal)}đ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textDark,
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

  Widget _buildPaymentCard(OrderResponse order) {
    return _buildCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppStrings.payment,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    AppStrings.paymentMethodPrefix,
                    style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                  ),
                  Text(
                    order.paymentMethod,
                    style: const TextStyle(fontSize: 12, color: AppColors.textDark),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                AppStrings.totalPayment,
                style: TextStyle(fontSize: 12, color: AppColors.textDark),
              ),
              const SizedBox(height: 4),
              Text(
                '${_formatCurrency(order.totalAmount)}đ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.accentDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
