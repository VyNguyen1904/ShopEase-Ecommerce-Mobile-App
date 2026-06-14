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
          'Chi tiết sản phẩm',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        _buildDetailRow('Danh mục', product.category),
        _buildDetailRow('Tình trạng', 'Mới'),
        _buildDetailRow('Kho hàng', 'Sẵn hàng'),
        _buildDetailRow('Giao từ', 'Hà Nội'),
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
