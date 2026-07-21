import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/order_model.dart';

class OrderInfoCard extends StatelessWidget {
  final OrderResponse order;
  const OrderInfoCard({super.key, required this.order});

  String _mapStatus(OrderResponse order) {
    if (order.status == OrderStatus.PENDING &&
        order.paymentMethod.toUpperCase() == 'VNPAY' &&
        order.paymentStatus == PaymentStatus.PENDING) {
      return 'Chờ thanh toán';
    }
    switch (order.status) {
      case OrderStatus.PENDING:
        return 'Chờ xác nhận';
      case OrderStatus.CONFIRMED:
      case OrderStatus.PACKED:
        return 'Đang xử lý';
      case OrderStatus.SHIPPED:
        return AppStrings.shipping;
      case OrderStatus.DELIVERED:
        return AppStrings.delivered;
      case OrderStatus.CANCELLED:
        return AppStrings.cancelled;
      case OrderStatus.FAILED:
        return 'Thanh toán thất bại';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.FAILED:
        return Colors.red;
      case OrderStatus.CANCELLED:
        return Colors.red[300]!;
      case OrderStatus.DELIVERED:
        return Colors.green;
      case OrderStatus.SHIPPED:
        return Colors.orange;
      case OrderStatus.PENDING:
        return Colors.amber[700]!;
      default:
        return AppColors.primaryDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
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
              color: _getStatusColor(order.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _mapStatus(order),
              style: TextStyle(
                color: _getStatusColor(order.status),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderTimelineCard extends StatelessWidget {
  final OrderResponse order;
  const OrderTimelineCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    bool isConfirmed =
        order.status == OrderStatus.CONFIRMED ||
        order.status == OrderStatus.PACKED ||
        order.status == OrderStatus.SHIPPED ||
        order.status == OrderStatus.DELIVERED;
    bool isShipping =
        order.status == OrderStatus.SHIPPED ||
        order.status == OrderStatus.DELIVERED;
    bool isDelivered = order.status == OrderStatus.DELIVERED;

    return _BaseCard(
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
}

class OrderAddressCard extends StatelessWidget {
  final OrderResponse order;
  const OrderAddressCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
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
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${order.shipStreet}, ${order.shipDistrict}, ${order.shipCity}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderProductsCard extends StatelessWidget {
  final OrderResponse order;
  const OrderProductsCard({super.key, required this.order});

  String _formatCurrency(double amount) {
    return amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
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
                      p.productImage.isNotEmpty
                          ? p.productImage
                          : 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
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
}

class OrderPaymentCard extends StatelessWidget {
  final OrderResponse order;
  const OrderPaymentCard({super.key, required this.order});

  String _formatCurrency(double amount) {
    return amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isDiscount = false,
    bool isShipping = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? AppColors.textDark : AppColors.textGrey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal
                  ? AppColors.accentDark
                  : (isDiscount
                        ? Colors.red
                        : (isShipping
                              ? Colors.orange[700]
                              : AppColors.textDark)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
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
          const SizedBox(height: 12),

          // Payment Method & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: order.paymentMethod.toUpperCase() == 'VNPAY'
                      ? Colors.blue[50]
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: order.paymentMethod.toUpperCase() == 'VNPAY'
                        ? Colors.blue[200]!
                        : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  order.paymentMethod.toUpperCase() == 'VNPAY'
                      ? 'VNPay'
                      : (order.paymentMethod.toUpperCase() == 'COD'
                            ? 'Thanh toán khi nhận hàng'
                            : order.paymentMethod),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: order.paymentMethod.toUpperCase() == 'VNPAY'
                        ? Colors.blue[800]
                        : AppColors.textDark,
                  ),
                ),
              ),
              Row(
                children: [
                  const Text(
                    "Trạng thái: ",
                    style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                  ),
                  Text(
                    order.paymentStatus == PaymentStatus.PAID
                        ? "Đã thanh toán"
                        : (order.paymentStatus == PaymentStatus.FAILED
                              ? "Thất bại"
                              : "Chưa thanh toán"),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: order.paymentStatus == PaymentStatus.PAID
                          ? Colors.green
                          : (order.paymentStatus == PaymentStatus.FAILED
                                ? Colors.red
                                : Colors.orange),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 16),

          // Pricing details
          _buildSummaryRow(
            'Tổng tiền hàng',
            '${_formatCurrency(order.subtotal)}đ',
          ),
          _buildSummaryRow(
            'Phí vận chuyển',
            '+ ${_formatCurrency(order.shippingFee)}đ',
            isShipping: true,
          ),
          if (order.discountAmount > 0)
            _buildSummaryRow(
              'Khuyến mãi',
              '- ${_formatCurrency(order.discountAmount)}đ',
              isDiscount: true,
            ),

          const SizedBox(height: 4),
          _buildSummaryRow(
            'Tổng thanh toán',
            '${_formatCurrency(order.totalAmount)}đ',
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _BaseCard extends StatelessWidget {
  final Widget child;
  const _BaseCard({required this.child});

  @override
  Widget build(BuildContext context) {
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
