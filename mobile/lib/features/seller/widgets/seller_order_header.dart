import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/order_model.dart';

class SellerOrderHeader extends StatelessWidget {
  final OrderResponse order;
  final int step;
  final List<String> statusTexts;

  const SellerOrderHeader({
    super.key,
    required this.order,
    required this.step,
    required this.statusTexts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${order.id.split('-').last.toUpperCase()}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: (step == 0 || step == -2)
                      ? const Color(0xFFFFF7ED)
                      : (step == 3
                            ? const Color(0xFFEAF5F6)
                            : const Color(0xFFECEFFF)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  step == -2
                      ? AppStrings.pending
                      : (step == -1 ? AppStrings.cancelled : statusTexts[step]),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: (step == 0 || step == -2)
                        ? const Color(0xFFD97706)
                        : (step == 3
                              ? AppColors.primary
                              : const Color(0xFF3B82F6)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${DateFormat('dd/MM/yyyy • HH:mm').format(order.createdAt)}  •  ${AppStrings.paymentMethodPrefix} ${order.paymentMethod}',
            style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}
