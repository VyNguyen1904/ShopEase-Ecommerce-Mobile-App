import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/order_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/order_provider.dart';
import '../widgets/order_card.dart';
import '../widgets/orders_empty_state.dart';

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
    'Chờ thanh toán',
    AppStrings.pending,
    AppStrings.processing,
    AppStrings.shipping,
    AppStrings.delivered,
    AppStrings.cancelled,
  ];

  String _mapStatus(OrderResponse order) {
    // VNPay orders awaiting payment
    if (order.status == OrderStatus.PENDING &&
        order.paymentMethod.toUpperCase() == 'VNPAY' &&
        order.paymentStatus == PaymentStatus.PENDING) {
      return 'Chờ thanh toán';
    }
    switch (order.status) {
      case OrderStatus.PENDING:
        return AppStrings.pending;
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Chờ thanh toán':
        return Colors.orange[700]!;
      case AppStrings.delivered:
        return Colors.green;
      case AppStrings.shipping:
        return Colors.blue;
      case AppStrings.cancelled:
        return AppColors.alertRed;
      case 'Thanh toán thất bại':
        return Colors.red;
      case 'Đang xử lý':
        return Colors.blue;
      default:
        return AppColors.primary;
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
              tabAlignment: TabAlignment.center,
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 24),
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
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);

    // Still loading auth state — show spinner
    if (userAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Not logged in
    if (userAsync.value == null) {
      return const OrdersLoginPrompt();
    }

    // Logged in — load orders
    return ref.watch(userOrdersProvider).when(
      data: (orders) => _buildOrderTabs(orders),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${AppStrings.errorPrefix}$e')),
    );
  }

  Widget _buildOrderTabs(List<OrderResponse> orders) {
    return TabBarView(
      controller: _tabController,
      children: _tabs.map((tab) {
        final filtered = tab == AppStrings.all
            ? orders
            : orders.where((o) => _mapStatus(o) == tab).toList();

        if (filtered.isEmpty) return const OrdersEmptyState();

        return ListView.separated(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 120,
          ),
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final order = filtered[index];
            final statusStr = _mapStatus(order);
            final statusColor = _getStatusColor(statusStr);

            return Column(
              children: [
                OrderCard(
                  order: order,
                  statusStr: statusStr,
                  statusColor: statusColor,
                ),
                const SizedBox(height: 12),
                OrderCardActions(order: order, statusStr: statusStr),
              ],
            );
          },
        );
      }).toList(),
    );
  }
}
