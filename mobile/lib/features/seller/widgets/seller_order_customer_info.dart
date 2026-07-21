import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/order_model.dart';
import 'seller_order_detail_widgets.dart';

class SellerOrderCustomerInfo extends StatelessWidget {
  final OrderResponse order;

  const SellerOrderCustomerInfo({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SellerSectionContainer(
          title: AppStrings.customerInfo,
          icon: Icons.person_outline,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.shipRecipient,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '📞 ${order.shipPhone}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.chat_bubble_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SellerSectionContainer(
          title: AppStrings.shippingAddress,
          icon: Icons.location_on_outlined,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          order.shipRecipient,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          AppStrings.defaultAddress,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${order.shipStreet}, ${order.shipDistrict}, ${order.shipCity}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textGrey,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '📞 ${order.shipPhone}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=200&auto=format&fit=crop&q=80',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
