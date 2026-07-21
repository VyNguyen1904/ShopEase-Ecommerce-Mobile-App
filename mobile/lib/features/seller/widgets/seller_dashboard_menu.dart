import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import 'seller_action_item.dart';

class SellerDashboardMenu extends StatelessWidget {
  const SellerDashboardMenu({super.key});

  @override
  Widget build(BuildContext context) {
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
                context.push(AppRoutes.sellerAddProduct);
              },
            ),
            SellerActionItem(
              icon: Icons.receipt_long_outlined,
              label: AppStrings.orders,
              onTap: () {
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
}
