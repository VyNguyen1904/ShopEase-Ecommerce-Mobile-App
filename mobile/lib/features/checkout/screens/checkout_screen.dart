// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
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

import '../widgets/checkout_address_card.dart';
import '../widgets/checkout_selected_items.dart';
import '../widgets/checkout_shipping_options.dart';
import '../widgets/checkout_discount_section.dart';
import '../widgets/checkout_payment_options.dart';
import '../widgets/checkout_order_summary.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final List<CartItem>? directItems;

  const CheckoutScreen({super.key, this.directItems});

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

    final selectedItems = widget.directItems ?? 
        (cartState.value?.items.where((i) => i.selected).toList() ?? []);
    final subtotal = widget.directItems != null
        ? selectedItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity))
        : (cartState.value?.subtotal ?? 0);

    final double baseShippingFee = _selectedShipping == 'nhanh' ? 32000 : 15000;
    final double shippingFee = subtotal >= 500000 ? 0 : baseShippingFee;
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
        title: const Text(
          AppStrings.proceedToCheckout,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CheckoutSectionTitle(title: AppStrings.shippingAddress),
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
            const CheckoutSectionTitle(title: AppStrings.selectedItems),
            CheckoutSelectedItems(items: selectedItems),
            const SizedBox(height: 24),
            const CheckoutSectionTitle(title: AppStrings.shippingUnit),
            CheckoutShippingOptions(
              selectedShipping: _selectedShipping,
              onChanged: (val) => setState(() => _selectedShipping = val),
            ),
            const SizedBox(height: 24),
            const CheckoutSectionTitle(title: AppStrings.discountCoins),
            CheckoutDiscountSection(
              useCoins: _useCoins,
              onUseCoinsChanged: (val) => setState(() => _useCoins = val),
            ),
            const SizedBox(height: 24),
            const CheckoutSectionTitle(title: AppStrings.paymentMethod),
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
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(AppStrings.missingAddressError)));
              return;
            }
            if (items.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(AppStrings.cartEmptyError)));
              return;
            }

            setState(() => _isLoading = true);
            try {
              final addrParts = address.address2.split(', ');
              final district = addrParts.length > 1 ? addrParts[0] : (address.address2.isNotEmpty ? address.address2 : 'N/A');
              final city = addrParts.length > 1 ? addrParts[1] : (address.address2.isNotEmpty ? address.address2 : 'N/A');

              final req = CreateOrderRequest(
                items: items.map((i) => OrderItemRequest(productId: i.productId, quantity: i.quantity, color: i.color, size: i.size)).toList(),
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
                      cartNotifier.removeItem(item.itemId);
                    }
                    return;
                  }
                }
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(AppStrings.orderSuccess)));
                context.go(AppRoutes.orderDetailPath(newOrder.id));
              }

              // Only clear from cart if we are checking out from cart
              if (widget.directItems == null) {
                final cartNotifier = ref.read(cartProvider.notifier);
                for (var item in items) {
                  cartNotifier.removeItem(item.itemId);
                }
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${AppStrings.errorPrefix}$e')));
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
                AppStrings.placeOrder,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
