import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/providers/order_provider.dart';
import '../../../core/models/order_model.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/notification_provider.dart';

class SellerOrdersScreen extends ConsumerStatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  ConsumerState<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends ConsumerState<SellerOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _mapStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.PENDING:
        return AppStrings.newStatus;
      case OrderStatus.CONFIRMED:
        return AppStrings.processingStatus;
      case OrderStatus.PACKED:
        return AppStrings.packedStatus;
      case OrderStatus.SHIPPED:
        return AppStrings.shipping;
      case OrderStatus.DELIVERED:
        return AppStrings.delivered;
      case OrderStatus.CANCELLED:
        return AppStrings.cancelled;
      case OrderStatus.FAILED:
        return 'Thất bại';
    }
  }

  Color _getStatusColor(String status) {
    if (status == AppStrings.delivered) {
      return Colors.green;
    } else if (status == AppStrings.cancelled) {
      return Colors.red;
    } else {
      return Colors.orange;
    }
  }

  Color _getStatusBgColor(String status) {
    if (status == AppStrings.delivered) {
      return Colors.green.shade50;
    } else if (status == AppStrings.cancelled) {
      return Colors.red.shade50;
    } else {
      return Colors.orange.shade50;
    }
  }

  String _formatCurrency(double amount) {
    return amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure WebSocket is active to receive real-time updates
    ref.watch(notificationListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textDark, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          AppStrings.myOrders,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textGrey,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: AppStrings.all),
                Tab(text: AppStrings.newStatus),
                Tab(text: AppStrings.processingStatus),
                Tab(text: AppStrings.delivered),
                Tab(text: AppStrings.cancelled),
              ],
            ),
          ),
        ),
      ),
      body: ref.watch(sellerOrdersProvider).when(
        data: (orders) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrderList(orders, AppStrings.all),
              _buildOrderList(orders, AppStrings.newStatus),
              _buildOrderList(orders, AppStrings.processingStatus),
              _buildOrderList(orders, AppStrings.delivered),
              _buildOrderList(orders, AppStrings.cancelled),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${AppStrings.errorPrefix}$e')),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.receipt_long, color: Colors.white),
            label: const Text(
              AppStrings.viewAllOrders,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF044851), // Dark teal from design
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList(List<OrderResponse> orders, String tabStatus) {
    final filteredOrders = tabStatus == AppStrings.all 
      ? orders 
      : orders.where((o) {
          final st = _mapStatus(o.status);
          if (tabStatus == AppStrings.processingStatus && (st == AppStrings.processingStatus || st == AppStrings.shipping)) return true;
          return st == tabStatus;
        }).toList();

    if (filteredOrders.isEmpty) {
      return const Center(child: Text(AppStrings.noOrdersList, style: TextStyle(color: AppColors.textGrey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return _buildOrderItem(order);
      },
    );
  }

  Widget _buildOrderItem(OrderResponse order) {
    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.sellerOrderDetailPath(order.id));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.bgLight,
              child: Text(
                order.shipRecipient.isNotEmpty ? order.shipRecipient[0].toUpperCase() : 'U',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${order.id.split('-').last.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.shipRecipient,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM/yyyy • HH:mm').format(order.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${_formatCurrency(order.totalAmount)}đ',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusBgColor(_mapStatus(order.status)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _mapStatus(order.status),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(_mapStatus(order.status)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textDark,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
