import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/order_provider.dart';
import '../../../core/models/order_model.dart';
import '../../../core/router/app_routes.dart';
import '../widgets/order_bottom_actions.dart';
import '../widgets/order_detail_cards.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

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
              context.go(AppRoutes.orders);
            }
          },
        ),
        title: const Text(
          AppStrings.orderDetailsTitle,
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
                OrderInfoCard(order: order),
                const SizedBox(height: 16),
                OrderTimelineCard(order: order),
                const SizedBox(height: 16),
                OrderAddressCard(order: order),
                const SizedBox(height: 16),
                OrderProductsCard(order: order),
                const SizedBox(height: 16),
                OrderPaymentCard(order: order),
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
}
