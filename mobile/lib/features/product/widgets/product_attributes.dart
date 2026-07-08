import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/product.dart';

class ProductAttributes extends StatelessWidget {
  final Product product;

  const ProductAttributes({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.productDetailsTitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        if (product.material != null && product.material!.isNotEmpty)
          _buildDetailRow(AppStrings.materialLabel, product.material!),
        if (product.fit != null && product.fit!.isNotEmpty)
          _buildDetailRow(AppStrings.fitLabel, product.fit!),
        if (product.careInstructions != null && product.careInstructions!.isNotEmpty)
          _buildDetailRow(AppStrings.careLabel, product.careInstructions!),
        if (product.features.isNotEmpty)
          ...product.features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: AppColors.textGrey)),
                    Expanded(child: Text(f, style: const TextStyle(color: AppColors.textDark, fontSize: 14))),
                  ],
                ),
              )),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
