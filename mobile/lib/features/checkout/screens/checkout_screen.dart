// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../orders/providers/order_provider.dart';
import '../../../core/models/cart_model.dart';
import '../../../core/models/order_model.dart';
import '../../../core/providers/payment_provider.dart';
import '../../../core/models/payment_model.dart';
import '../../../core/models/address_model.dart';
import '../widgets/checkout_section_title.dart';
import '../widgets/checkout_stepper.dart';
import '../widgets/checkout_address_card.dart';
import '../widgets/checkout_selected_items.dart';
import '../widgets/checkout_shipping_options.dart';
import '../widgets/checkout_discount_section.dart';
import '../widgets/checkout_payment_options.dart';
import '../widgets/checkout_order_summary.dart';

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
  AddressModel? _selectedAddress;

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final userState = ref.watch(userProfileProvider);

    final selectedItems = cartState.value?.items.where((i) => i.selected).toList() ?? [];
    final subtotal = cartState.value?.subtotal ?? 0;

    final double shippingFee = _selectedShipping == 'nhanh' ? 32000 : 15000;
    final double discount = _useCoins ? 2000 : 0;
    final double totalAmount = subtotal + shippingFee - discount;

    final defaultAddress = userState.value?.addresses.where((a) => a.isDefault).firstOrNull 
        ?? userState.value?.addresses.firstOrNull;

    final addressToUse = _selectedAddress ?? defaultAddress;

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
            const CheckoutSectionTitle(title: 'Địa chỉnhận hàng'),
            CheckoutAddressCard(
              address: addressToUse,
              onTap: () async {
                final result = await context.push<AddressModel>(
                  AppRoutes.address,
                  extra: {'isSelecting': true},
                );
                if (result != null) {
                  setState(() => _selectedAddress = result);
                }
              },
            ),
            const SizedBox(height: 24),
            const CheckoutSectionTitle(title: 'Sản phẩm đã chọn'),
            CheckoutSelectedItems(items: selectedItems),
            const SizedBox(height: 24),
            const CheckoutSectionTitle(title: 'Đơn vịvận chuyển'),
            CheckoutShippingOptions(
              selectedShipping: _selectedShipping,
              onChanged: (val) => setState(() => _selectedShipping = val),
            ),
            const SizedBox(height: 24),
            const CheckoutSectionTitle(title: 'Mã giảm giá / Xu'),
            CheckoutDiscountSection(
              useCoins: _useCoins,
              onUseCoinsChanged: (val) => setState(() => _useCoins = val),
            ),
            const SizedBox(height: 24),
            const CheckoutSectionTitle(title: 'Phương thức thanh toán'),
            CheckoutPaymentOptions(
              selectedPayment: _selectedPayment,
              onChanged: (val) => setState(() => _selectedPayment = val),
            ),
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
      bottomNavigationBar: _buildBottomBar(selectedItems, addressToUse, totalAmount),
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
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng thêm địa chỉnhận hàng!')));
              return;
            }
            if (items.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Giỏ hàng trống!')));
              return;
            }

            setState(() => _isLoading = true);
            try {
              final addrParts = address.address2.split(', ');
              final district = addrParts.length > 1 ? addrParts[0] : (address.address2.isNotEmpty ? address.address2 : 'N/A');
              final city = addrParts.length > 1 ? addrParts[1] : (address.address2.isNotEmpty ? address.address2 : 'N/A');

              final req = CreateOrderRequest(
                items: items.map((i) => OrderItemRequest(productId: i.productId, quantity: i.quantity)).toList(),
                shipRecipient: address.name,
                shipPhone: address.phone,
                shipStreet: address.address1,
                shipDistrict: district,
                shipCity: city,
                paymentMethod: _selectedPayment.toUpperCase(),
                note: '',
              );

              final orderService = ref.read(orderServiceProvider);
              final newOrder = await orderService.createOrder(req);

              if (_selectedPayment != 'cod') {
                final paymentReq = CheckoutPaymentRequest(
                  orderId: newOrder.id,
                  amount: totalAmount,
                  paymentMethod: _selectedPayment.toUpperCase(),
                );
                final paymentService = ref.read(paymentServiceProvider);
                final paymentResp = await paymentService.processCheckout(paymentReq);

                if (mounted) {
                  if (paymentResp.qrPayload != null && paymentResp.qrPayload!.isNotEmpty) {
                    context.go('/payment', extra: {
                      'orderId': newOrder.id,
                      'qrPayload': paymentResp.qrPayload,
                    });
                    
                    final cartNotifier = ref.read(cartProvider.notifier);
                    for (var item in items) {
                      cartNotifier.removeItem(item.productId);
                    }
                    return;
                  }
                }
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đặt hàng thành công!')));
                context.go(AppRoutes.orderDetailPath(newOrder.id));
              }

              final cartNotifier = ref.read(cartProvider.notifier);
              for (var item in items) {
                cartNotifier.removeItem(item.productId);
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
