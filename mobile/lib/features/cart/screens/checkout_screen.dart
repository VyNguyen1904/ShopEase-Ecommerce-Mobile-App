// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_routes.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../../orders/providers/order_provider.dart';
import '../../../core/models/address_model.dart';
import '../../../core/models/cart_model.dart';
import '../widgets/checkout_components.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _selectedShipping = 'nhanh';
  String _selectedPayment = 'cod';
  bool _useCoins = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final userState = ref.watch(userProfileProvider);

    final selectedItems = cartState.value?.items.where((i) => i.selected).toList() ?? [];
    final subtotal = cartState.value?.subtotal ?? 0;

    final double shippingFee = _selectedShipping == 'nhanh' ? 32000 : 15000;
    final double discount = _useCoins ? 2000 : 0;
    final double totalAmount = subtotal + shippingFee - discount;

    final defaultAddress = userState.value?.addresses.where((a) => a.defaultAddress).firstOrNull 
        ?? userState.value?.addresses.firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textDark,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: const CheckoutStepper(),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CheckoutSectionTitle(title: 'Địa chỉ nhận hàng'),
            CheckoutAddressCard(address: defaultAddress),
            const SizedBox(height: 24),
            const CheckoutSectionTitle(title: 'Sản phẩm đã chọn'),
            CheckoutSelectedItems(items: selectedItems),
            const SizedBox(height: 24),
            const CheckoutSectionTitle(title: 'Đơn vị vận chuyển'),
            _buildShippingOptions(),
            const SizedBox(height: 24),
            const CheckoutSectionTitle(title: 'Mã giảm giá / Xu'),
            _buildDiscountSection(),
            const SizedBox(height: 24),
            const CheckoutSectionTitle(title: 'Phương thức thanh toán'),
            _buildPaymentOptions(),
            const SizedBox(height: 24),
            CheckoutOrderSummary(
              subtotal: subtotal,
              shippingFee: shippingFee,
              discount: discount,
              totalAmount: totalAmount,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(selectedItems, defaultAddress, totalAmount),
    );
  }

  Widget _buildShippingOptions() {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          RadioListTile<String>(
            value: 'nhanh',
            groupValue: _selectedShipping,
            onChanged: (val) => setState(() => _selectedShipping = val!),
            activeColor: AppColors.primary,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            title: const Text(
              'Nhanh (2–3 ngày)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            secondary: const Text(
              '32.000đ',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: AppColors.border,
          ),
          RadioListTile<String>(
            value: 'tietkiem',
            groupValue: _selectedShipping,
            onChanged: (val) => setState(() => _selectedShipping = val!),
            activeColor: AppColors.primary,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            title: const Text(
              'Tiết kiệm (3–5 ngày)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            secondary: const Text(
              '15.000đ',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Nhập mã giảm giá',
                    hintStyle: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.bgLight,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Áp dụng',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Checkbox(
              value: _useCoins,
              onChanged: (val) => setState(() => _useCoins = val!),
              activeColor: AppColors.primary,
            ),
            RichText(
              text: const TextSpan(
                style: TextStyle(color: AppColors.textDark, fontSize: 14),
                children: [
                  TextSpan(text: 'Dùng '),
                  TextSpan(
                    text: '2.000 xu ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.alertRed,
                    ),
                  ),
                  TextSpan(
                    text: '(-2.000đ)',
                    style: TextStyle(color: AppColors.alertRed),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Switch(
              value: _useCoins,
              onChanged: (val) => setState(() => _useCoins = val),
              activeThumbColor: AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentOptions() {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildPaymentRadio(
            'cod',
            'Thanh toán khi nhận hàng (COD)',
            isSelected: _selectedPayment == 'cod',
          ),
          const Divider(
            height: 1,
            indent: 50,
            endIndent: 16,
            color: AppColors.border,
          ),
          _buildPaymentRadio(
            'vnpay',
            'VNPay',
            isSelected: _selectedPayment == 'vnpay',
          ),
          const Divider(
            height: 1,
            indent: 50,
            endIndent: 16,
            color: AppColors.border,
          ),
          _buildPaymentRadio(
            'zalopay',
            'Ví ZaloPay',
            subtitle: '(Giảm đến 150.000đ)',
            isSelected: _selectedPayment == 'zalopay',
          ),
          const Divider(
            height: 1,
            indent: 50,
            endIndent: 16,
            color: AppColors.border,
          ),
          _buildPaymentRadio(
            'credit',
            'Thẻ tín dụng / ATM',
            isSelected: _selectedPayment == 'credit',
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRadio(
    String value,
    String title, {
    String? subtitle,
    bool isSelected = false,
  }) {
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedPayment,
      onChanged: (val) => setState(() => _selectedPayment = val!),
      activeColor: AppColors.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      title: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textDark,
            fontWeight: FontWeight.w500,
          ),
          children: [
            TextSpan(text: title),
            if (subtitle != null) ...[
              const TextSpan(text: ' '),
              TextSpan(
                text: subtitle,
                style: const TextStyle(color: AppColors.textGrey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(List<CartItem> items, AddressModel? address, double totalAmount) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -4),
              blurRadius: 16,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : () async {
            if (address == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng thêm địa chỉ nhận hàng!')));
              return;
            }
            if (items.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Giỏ hàng trống!')));
              return;
            }

            setState(() => _isLoading = true);
            try {
              final itemsReq = items.map((e) => {
                'productId': e.productId,
                'quantity': e.quantity,
              }).toList();

              final req = {
                'items': itemsReq,
                'shipRecipient': address.recipientName,
                'shipPhone': address.phone,
                'shipStreet': address.street,
                'shipDistrict': address.district,
                'shipCity': address.city,
                'paymentMethod': _selectedPayment.toUpperCase(),
                'note': '',
              };

              final orderService = ref.read(orderServiceProvider);
              final newOrder = await orderService.createOrder(req);

              ref.invalidate(cartProvider); // Clear cart

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đặt hàng thành công!')));
                context.go(AppRoutes.orderDetailPath(newOrder.id));
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
              }
            } finally {
              if (mounted) setState(() => _isLoading = false);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.alertRed,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: _isLoading 
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.lock_outline, size: 20),
              SizedBox(width: 8),
              Text(
                'Đặt hàng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
