import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/cart_model.dart';

class CheckoutSelectedItems extends StatelessWidget {
  final List<CartItem> items;
  const CheckoutSelectedItems({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Text(AppStrings.noSelectedItems);
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.productImageUrl ?? '',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 50, height: 50, color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 20, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.productName ?? AppStrings.product, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                        [item.color, item.size].where((e) => e != null && e.isNotEmpty).join(', ').isNotEmpty 
                            ? [item.color, item.size].where((e) => e != null && e.isNotEmpty).join(', ') 
                            : (item.productVariant ?? AppStrings.defaultVariant),
                        style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                      ),
                      const SizedBox(height: 4),
                      Text('x${item.quantity}', style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                    ],
                  ),
                ),
                Text(
                  '${item.subtotal.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
