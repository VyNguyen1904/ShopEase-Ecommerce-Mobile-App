import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/models/cart_model.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textDark,
            size: 20,
          ),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
        title: const Text(
          'Giỏ hàng',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: cartState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.textDark),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Đã có lỗi xảy ra', style: TextStyle(color: Colors.red)),
              TextButton(
                onPressed: () => ref.read(cartProvider.notifier).fetchCart(),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (cart) {
          final cartItems = cart.items;
          final bool isAllSelected =
              cartItems.isNotEmpty && cartItems.every((item) => item.selected);

          return Column(
            children: [
              // Select All Checkbox
              if (cartItems.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isAllSelected,
                        onChanged: (bool? value) {
                          ref
                              .read(cartProvider.notifier)
                              .toggleAll(value ?? false);
                        },
                        activeColor: AppColors.textDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Text(
                        'Chọn tất cả',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),

              // Cart Items
              Expanded(
                child: cartItems.isEmpty
                    ? const Center(child: Text('Giỏ hàng trống'))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: cartItems.length,
                        separatorBuilder: (context, index) =>
                            _buildDottedDivider(),
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return _buildCartItem(item);
                        },
                      ),
              ),

              // Bottom Checkout Section
              if (cartItems.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Coupon Code
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.bgLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_activity_outlined,
                                color: AppColors.textLight,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Thêm mã giảm giá',
                                  style: TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade400,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  children: [
                                    Text(
                                      '-10%',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Total Amount
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tổng cộng:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Mua để nhận điểm',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${cart.subtotal.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Miễn phí giao hàng',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Checkout Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () => context.push(AppRoutes.checkout),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.textDark,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Tiến hành thanh toán',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          Checkbox(
            value: item.selected,
            onChanged: (bool? value) {
              ref
                  .read(cartProvider.notifier)
                  .toggleItemSelection(item.productId, value ?? false);
            },
            activeColor: AppColors.textDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 8),

          // Image
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.bgLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.productImageUrl != null
                  ? Image.network(
                      item.productImageUrl!,
                      fit: BoxFit.cover,
                      cacheWidth: 144,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image, color: Colors.grey),
                    )
                  : const Icon(Icons.image, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.productName ?? 'Sản phẩm ${item.productId}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        ref
                            .read(cartProvider.notifier)
                            .removeItem(item.productId);
                      },
                      child: const Icon(
                        Icons.close,
                        color: AppColors.textLight,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.productVariant ?? 'Mặc định',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Prices
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.price.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),

                    // Quantity Selector
                    Container(
                      height: 36,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            onPressed: () {
                              if (item.quantity > 1) {
                                ref
                                    .read(cartProvider.notifier)
                                    .updateQuantity(
                                      item.productId,
                                      item.quantity - 1,
                                    );
                              }
                            },
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            constraints: const BoxConstraints(),
                            splashRadius: 20,
                            color: AppColors.textDark,
                          ),
                          Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            onPressed: () {
                              ref
                                  .read(cartProvider.notifier)
                                  .updateQuantity(
                                    item.productId,
                                    item.quantity + 1,
                                  );
                            },
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            constraints: const BoxConstraints(),
                            splashRadius: 20,
                            color: AppColors.textDark,
                          ),
                        ],
                      ),
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

  Widget _buildDottedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boxWidth = constraints.constrainWidth();
          const dashWidth = 4.0;
          const dashHeight = 1.0;
          final dashCount = (boxWidth / (2 * dashWidth)).floor();
          return Flex(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            direction: Axis.horizontal,
            children: List.generate(dashCount, (_) {
              return const SizedBox(
                width: dashWidth,
                height: dashHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: AppColors.border),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
