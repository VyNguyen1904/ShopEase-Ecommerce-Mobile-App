import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/order_provider.dart';
import '../../../core/models/order_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/constants/app_strings.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../widgets/seller_stat_card.dart';
import '../widgets/seller_action_item.dart';
import '../widgets/seller_order_item.dart';

class SellerDashboardScreen extends ConsumerWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(ref),
              const SizedBox(height: 24),
              _buildStatsCards(ref),
              const SizedBox(height: 32),
              _buildQuickActions(context),
              const SizedBox(height: 32),
              _buildRecentOrders(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final userName = userAsync.maybeWhen(
      data: (user) => user?.fullName.split(' ').last ?? 'Seller',
      orElse: () => 'Seller',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              '${AppStrings.helloPrefix}$userName',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          AppStrings.shopOverviewDesc,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards(WidgetRef ref) {
    final ordersAsync = ref.watch(sellerOrdersProvider);
    
    int totalOrders = 0;
    double totalRevenue = 0;
    
    ordersAsync.whenData((orders) {
      totalOrders = orders.length;
      for (var order in orders) {
        if (order.status != OrderStatus.CANCELLED) {
          totalRevenue += order.totalAmount;
        }
      }
    });

    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Row(
      children: [
        Expanded(
          child: SellerStatCard(
            title: AppStrings.revenue,
            value: formatCurrency.format(totalRevenue),
            valueColor: AppColors.primary,
            trend: AppStrings.totalRevenue,
            trendColor: Colors.green,
            icon: Icons.monetization_on_outlined,
            iconBgColor: AppColors.primary.withValues(alpha: 0.1),
            iconColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SellerStatCard(
            title: AppStrings.orders,
            value: '$totalOrders',
            valueColor: AppColors.textDark,
            trend: AppStrings.totalOrders,
            trendColor: Colors.green,
            icon: Icons.shopping_bag_outlined,
            iconBgColor: AppColors.accent.withValues(alpha: 0.1),
            iconColor: AppColors.accent,
          ),
        ),
      ],
    );
  }


  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.quickActions,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SellerActionItem(
              icon: Icons.inventory_2_outlined,
              label: AppStrings.addProduct,
              onTap: () {
                // Navigate to add product screen
                context.push(AppRoutes.sellerAddProduct);
              },
            ),
            SellerActionItem(
              icon: Icons.receipt_long_outlined,
              label: AppStrings.orders,
              onTap: () {
                // Navigate to seller orders
                context.push(AppRoutes.sellerOrders);
              },
            ),
            SellerActionItem(
              icon: Icons.campaign_outlined,
              label: AppStrings.promotions,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(AppStrings.promotionFeatureDev)),
                );
              },
            ),
            SellerActionItem(
              icon: Icons.pie_chart_outline,
              label: AppStrings.reports,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(AppStrings.reportFeatureDev)),
                );
              },
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildRecentOrders(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(sellerOrdersProvider);
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              AppStrings.recentOrders,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Row(
              children: [
                const Text(
                  AppStrings.viewAll,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  size: 14,
                  color: AppColors.textGrey,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: ordersAsync.when(
            data: (orders) {
              if (orders.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: Text(AppStrings.noOrdersFound)),
                );
              }
              final recentOrders = orders.take(5).toList();
              return Column(
                children: List.generate(recentOrders.length, (index) {
                  final order = recentOrders[index];
                  return SellerOrderItem(
                    id: '#${order.id.split('-').last.toUpperCase()}',
                    date: DateFormat('dd/MM/yyyy • HH:mm').format(order.createdAt),
                    price: formatCurrency.format(order.totalAmount),
                    status: _mapStatus(order.status),
                    statusColor: _getStatusColor(order.status),
                    avatarUrl: 'https://i.pravatar.cc/150?img=${10 + index}',
                    showDivider: index < recentOrders.length - 1,
                    onTap: () {
                      context.push(AppRoutes.sellerOrderDetailPath(order.id));
                    },
                  );
                }),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, s) => Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(child: Text('${AppStrings.loadOrderError}$e')),
            ),
          ),
        ),
      ],
    );
  }


  String _mapStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.PENDING:
        return AppStrings.pending;
      case OrderStatus.CONFIRMED:
        return AppStrings.confirmed;
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

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.PENDING:
        return AppColors.accent;
      case OrderStatus.CONFIRMED:
        return Colors.blue;
      case OrderStatus.PACKED:
        return Colors.blueGrey;
      case OrderStatus.SHIPPED:
        return Colors.orange;
      case OrderStatus.DELIVERED:
        return Colors.green;
      case OrderStatus.CANCELLED:
        return Colors.red;
      case OrderStatus.FAILED:
        return Colors.red[700]!;
    }
  }

}
