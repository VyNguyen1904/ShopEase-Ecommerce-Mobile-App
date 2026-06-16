import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/providers/order_provider.dart';
import '../../../core/models/order_model.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = [
    AppStrings.all,
    AppStrings.pending,
    AppStrings.shipping,
    AppStrings.delivered,
    AppStrings.cancelled,
  ];

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppStrings.delivered:
        return Colors.green;
      case AppStrings.shipping:
        return Colors.orange;
      case AppStrings.cancelled:
        return AppColors.alertRed;
      default:
        return AppColors.primary;
    }
  }

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
        title: const Text(
          AppStrings.myOrders,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              dividerColor: Colors.transparent,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorPadding: EdgeInsets.zero,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textGrey,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            ),
          ),
        ),
      ),
      body: ref.watch(userOrdersProvider).when(
        data: (orders) {
          return TabBarView(
            controller: _tabController,
            children: _tabs.map((tab) {
              final filteredOrders = tab == AppStrings.all
                  ? orders
                  : orders.where((o) => _mapStatus(o.status) == tab).toList();

          if (filteredOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: AppColors.textLight.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    AppStrings.noOrdersFound,
                    style: TextStyle(color: AppColors.textGrey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 120,
            ),
            itemCount: filteredOrders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              final items = order.items;
              final statusStr = _mapStatus(order.status);
              final statusColor = _getStatusColor(statusStr);

              return GestureDetector(
                onTap: () {
                  context.push(AppRoutes.orderDetailPath(order.id));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${AppStrings.orderCodePrefix} ${order.id.split('-').last.toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusStr,
                              style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('dd MMM, yyyy').format(order.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1, color: AppColors.border),
                      ),
                      ...items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.border.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: Image.network(
                                    item.productImage.isNotEmpty ? item.productImage : 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&q=80',
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                    cacheWidth: 144,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              width: 72,
                                              height: 72,
                                              color: AppColors.bgLight,
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                color: AppColors.textGrey,
                                              ),
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
                                      item.productName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_formatCurrency(item.unitPrice)} đ',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${_formatCurrency(item.subtotal)} đ',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                        Text(
                                          'x${item.quantity}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textGrey,
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
                      }),
                      const Padding(
                        padding: EdgeInsets.only(top: 4, bottom: 12),
                        child: Divider(height: 1, color: AppColors.border),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${items.length} ${AppStrings.itemCount}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textGrey,
                            ),
                          ),
                          Row(
                            children: [
                              const Text(
                                AppStrings.totalPrice,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Text(
                                '${_formatCurrency(order.totalAmount)} đ',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (statusStr == AppStrings.pending)
                            OutlinedButton(
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text(AppStrings.cancelOrder, style: TextStyle(fontWeight: FontWeight.bold)),
                                    content: const Text(AppStrings.cancelPrompt),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text(AppStrings.no, style: TextStyle(color: AppColors.textGrey)),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text(AppStrings.cancelAction, style: TextStyle(color: AppColors.alertRed)),
                                      ),
                                    ],
                                  ),
                                );
                                
                                if (confirm == true && context.mounted) {
                                  // Must use rootNavigator because showDialog pushes to root by default
                                  // and we are inside a ShellRoute
                                  final rootNavigator = Navigator.of(context, rootNavigator: true);
                                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                                  
                                  try {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (_) => const Center(child: CircularProgressIndicator()),
                                    );
                                    
                                    await ref.read(orderServiceProvider).cancelOrder(order.id);
                                    
                                    rootNavigator.pop(); // close loading dialog
                                    ref.invalidate(userOrdersProvider); // refresh list
                                    
                                    scaffoldMessenger.showSnackBar(
                                      const SnackBar(content: Text(AppStrings.cancelOrderSuccess)),
                                    );
                                  } catch (e) {
                                    rootNavigator.pop(); // close loading dialog
                                    scaffoldMessenger.showSnackBar(
                                      SnackBar(content: Text('Lỗi: $e')),
                                    );
                                  }
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.alertRed),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                              ),
                              child: const Text(
                                AppStrings.cancelAction,
                                style: TextStyle(
                                  color: AppColors.alertRed,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          if (statusStr == AppStrings.delivered)
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                              ),
                              child: const Text(
                                AppStrings.reviewAction,
                                style: TextStyle(
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          if (statusStr == AppStrings.delivered || statusStr == AppStrings.pending)
                            const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: (statusStr == AppStrings.shipping || statusStr == AppStrings.pending)
                                  ? AppColors.primary
                                  : AppColors.textDark,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                            child: Text(
                              (statusStr == AppStrings.shipping || statusStr == AppStrings.pending)
                                  ? AppStrings.trackAction
                                  : AppStrings.reorderAction,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }
}
