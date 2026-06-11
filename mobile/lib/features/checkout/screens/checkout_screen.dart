// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_routes.dart';
import '../providers/cart_provider.dart';
import '../../../core/providers/order_provider.dart';
import '../../../core/models/order_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/payment_provider.dart';
import '../../../core/models/payment_model.dart';

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
        title: _buildStepper(),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Địa chỉ nhận hàng'),
            _buildAddressCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Đơn vị vận chuyển'),
            _buildShippingOptions(),
            const SizedBox(height: 24),
            _buildSectionTitle('Mã giảm giá / Xu'),
            _buildDiscountSection(),
            const SizedBox(height: 24),
            _buildSectionTitle('Phương thức thanh toán'),
            _buildPaymentOptions(),
            const SizedBox(height: 24),
            cartState.when(
              data: (cart) {
                final selectedItems = cart.items.where((i) => i.selected).toList();
                final subtotal = selectedItems.fold(0.0, (sum, i) => sum + (i.price * i.quantity));
                return _buildOrderSummary(subtotal);
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Lỗi: $e'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildStepper() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStepIndicator('1', isActive: true),
        _buildStepLine(),
        _buildStepIndicator('2', isActive: false),
        _buildStepLine(),
        _buildStepIndicator('3', isActive: false),
        const SizedBox(width: 8),
        const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: AppColors.textGrey,
        ),
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

  Widget _buildSectionTitle(String title) {
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

  Widget _buildAddressCard() {
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
              const Icon(
                Icons.person_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Jane Doe',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Mặc định',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '123 Nguyễn Huệ, P. Bến Nghé,',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const Text(
                  'Quận 1, TP. Hồ Chí Minh',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.delete_outline,
                      color: AppColors.alertRed,
                      size: 20,
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

  Widget _buildOrderSummary(double subtotal) {
    double shippingFee = _selectedShipping == 'nhanh' ? 32000 : 15000;
    double discount = _useCoins ? 2000 : 0;
    double total = subtotal + shippingFee - discount;

    return Column(
      children: [
        _buildSummaryRow('Tạm tính', '${subtotal.toInt()}đ'),
        const SizedBox(height: 8),
        _buildSummaryRow('Phí vận chuyển', '${shippingFee.toInt()}đ'),
        const SizedBox(height: 8),
        _buildSummaryRow('Giảm giá', '-${discount.toInt()}đ'),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tổng cộng',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Text(
              '${total.toInt()}đ',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.alertRed,
              ),
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
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textDark,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
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
          onPressed: _isLoading ? null : () => _placeOrder(),
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
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
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

  Future<void> _placeOrder() async {
    final cartState = ref.read(cartProvider);
    if (!cartState.hasValue) return;

    final items = cartState.value!.items.where((i) => i.selected).toList();
    if (items.isEmpty) return;

    final subtotal = items.fold(0.0, (sum, i) => sum + (i.price * i.quantity));
    final shippingFee = _selectedShipping == 'nhanh' ? 32000.0 : 15000.0;
    final discount = _useCoins ? 2000.0 : 0.0;
    final total = subtotal + shippingFee - discount;

    setState(() => _isLoading = true);
    try {
      final request = CreateOrderRequest(
        items: items.map((i) => OrderItemRequest(productId: i.productId, quantity: i.quantity)).toList(),
        shipRecipient: 'Jane Doe',
        shipPhone: '0123456789',
        shipStreet: '123 Nguyen Hue',
        shipDistrict: 'Q1',
        shipCity: 'HCMC',
        paymentMethod: _selectedPayment.toUpperCase(), // 'COD', 'VNPAY', 'ZALOPAY', 'CREDIT' 
      );

      final orderService = ref.read(orderServiceProvider);
      final createdOrder = await orderService.createOrder(request);

      // Remove items from cart
      final cartNotifier = ref.read(cartProvider.notifier);
      for (var item in items) {
        await cartNotifier.removeItem(item.productId);
      }

      // Process payment if not COD
      if (_selectedPayment != 'cod') {
        final paymentReq = CheckoutPaymentRequest(
          orderId: createdOrder.id,
          amount: total,
          paymentMethod: _selectedPayment.toUpperCase(),
        );
        final paymentService = ref.read(paymentServiceProvider);
        final paymentResp = await paymentService.processCheckout(paymentReq);

        if (mounted) {
          if (paymentResp.qrPayload != null && paymentResp.qrPayload!.isNotEmpty) {
            context.go('/payment', extra: {
              'orderId': createdOrder.id,
              'qrPayload': paymentResp.qrPayload,
            });
            return;
          }
        }
      }

      if (mounted) {
        context.go(AppRoutes.orders); // Navigate to orders page
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
