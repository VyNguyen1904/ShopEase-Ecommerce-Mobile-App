import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/models/address_model.dart';
import '../../../../core/models/cart_model.dart';

class CheckoutSectionTitle extends StatelessWidget {
  final String title;
  const CheckoutSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
    );
  }
}

class CheckoutStepper extends StatelessWidget {
  const CheckoutStepper({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStepIndicator('1', isActive: true),
        _buildStepLine(),
        _buildStepIndicator('2', isActive: false),
        _buildStepLine(),
        _buildStepIndicator('3', isActive: false),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textGrey),
      ],
    );
  }

  Widget _buildStepIndicator(String number, {required bool isActive}) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.bgLight,
        shape: BoxShape.circle,
        border: isActive ? null : Border.all(color: AppColors.border),
      ),
      alignment: Alignment.center,
      child: Text(
        number,
        style: TextStyle(
          color: isActive ? Colors.white : AppColors.textGrey,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildStepLine() {
    return Container(
      width: 40,
      height: 1,
      color: AppColors.border,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class CheckoutAddressCard extends StatelessWidget {
  final AddressModel? address;
  const CheckoutAddressCard({super.key, this.address});

  @override
  Widget build(BuildContext context) {
    if (address == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: InkWell(
          onTap: () => context.push(AppRoutes.address),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_location_alt_outlined, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Thêm địa chỉ nhận hàng', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${address!.recipientName} - ${address!.phone}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              if (address!.defaultAddress)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Mặc định', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${address!.street}, ${address!.district},',
                  style: const TextStyle(color: AppColors.textDark, fontSize: 14, height: 1.5),
                ),
                Text(
                  address!.city,
                  style: const TextStyle(color: AppColors.textDark, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => context.push(AppRoutes.address),
                      child: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CheckoutSelectedItems extends StatelessWidget {
  final List<CartItem> items;
  const CheckoutSelectedItems({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Text('Chưa có sản phẩm nào được chọn.');
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.productImageUrl ?? '',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 50, height: 50, color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 20, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.productName ?? 'Sản phẩm', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('x${item.quantity}', style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                    ],
                  ),
                ),
                Text(
                  '${item.subtotal.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class CheckoutOrderSummary extends StatelessWidget {
  final double subtotal;
  final double shippingFee;
  final double discount;
  final double totalAmount;

  const CheckoutOrderSummary({
    super.key,
    required this.subtotal,
    required this.shippingFee,
    required this.discount,
    required this.totalAmount,
  });

  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSummaryRow('Tạm tính', '${_formatPrice(subtotal)}đ'),
        const SizedBox(height: 8),
        _buildSummaryRow('Phí vận chuyển', '${_formatPrice(shippingFee)}đ'),
        const SizedBox(height: 8),
        _buildSummaryRow('Giảm giá', '-${_formatPrice(discount)}đ'),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tổng cộng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            Text(
              '${_formatPrice(totalAmount)}đ',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.alertRed),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textGrey)),
        Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textDark, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
