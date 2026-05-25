import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/selected_product_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _selectedColorIndex = 1;
  String _selectedSize = '9';
  bool _isFavorite = false;

  final List<Map<String, dynamic>> _colorOptions = [
    {'name': 'Trắng', 'color': Colors.white, 'hasBorder': true},
    {'name': 'Xanh Ngọc', 'color': AppColors.primary, 'hasBorder': false},
    {'name': 'Đen', 'color': Colors.black, 'hasBorder': false},
  ];

  @override
  Widget build(BuildContext context) {
    // Read product from Riverpod provider (set before navigation)
    final product = ref.watch(selectedProductProvider);
    final heroTag = ref.watch(selectedHeroTagProvider);

    if (product == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.textLight),
              const SizedBox(height: 12),
              const Text('Không tìm thấy sản phẩm'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      );
    }

    final discountPercent = product.discountPercentage;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header with back and favorite
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.arrow_back_ios,
                          color: AppColors.textDark, size: 22),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isFavorite = !_isFavorite;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite
                            ? AppColors.alertRed
                            : AppColors.textDark,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Large Image View
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Hero(
                    tag: heroTag.isNotEmpty
                        ? heroTag
                        : 'hero_img_${product.id}_v',
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image,
                            size: 100, color: AppColors.textLight);
                      },
                    ),
                  ),
                ),
              ),
            ),

            // 3. Scrollable Detail content
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Title
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.category,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textGrey,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Ratings Row
                      Row(
                        children: [
                          Row(
                            children: List.generate(
                              5,
                              (index) => Icon(
                                index < product.rating.floor()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${product.reviewsCount} đánh giá)',
                            style: const TextStyle(
                                fontSize: 14, color: AppColors.textGrey),
                          ),
                          const Spacer(),
                          Text(
                            '${product.salesCount} đã bán',
                            style: const TextStyle(
                                fontSize: 14, color: AppColors.textGrey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Pricing block
                      Row(
                        children: [
                          Text(
                            '${_formatCurrency(product.price)}đ',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                          ),
                          if (product.originalPrice != null) ...[
                            const SizedBox(width: 12),
                            Text(
                              '${_formatCurrency(product.originalPrice!)}đ',
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textLight,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accentLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '-$discountPercent%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Color selector
                      Text(
                        'Màu sắc: ${_colorOptions[_selectedColorIndex]['name']}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: List.generate(
                          _colorOptions.length,
                          (index) => GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColorIndex = index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              margin: const EdgeInsets.only(right: 12),
                              width: _selectedColorIndex == index ? 42 : 38,
                              height: _selectedColorIndex == index ? 42 : 38,
                              decoration: BoxDecoration(
                                color: _colorOptions[index]['color'],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _selectedColorIndex == index
                                      ? AppColors.primary
                                      : (_colorOptions[index]['hasBorder']
                                          ? AppColors.border
                                          : Colors.transparent),
                                  width:
                                      _selectedColorIndex == index ? 3.0 : 1,
                                ),
                                boxShadow: _selectedColorIndex == index
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        )
                                      ]
                                    : null,
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: _selectedColorIndex == index
                                    ? Icon(
                                        Icons.check,
                                        key: const ValueKey('checked'),
                                        color:
                                            _colorOptions[index]['color'] ==
                                                    Colors.white
                                                ? AppColors.primary
                                                : Colors.white,
                                        size: 20,
                                      )
                                    : const SizedBox.shrink(
                                        key: ValueKey('empty')),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Size Selector
                      const Text(
                        'Kích thước',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: product.sizes.map((size) {
                          final isSelected = _selectedSize == size;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSize = size;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              margin: const EdgeInsets.only(right: 12),
                              width: isSelected ? 48 : 42,
                              height: isSelected ? 48 : 42,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.accent
                                    : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.accent
                                      : AppColors.border,
                                  width: 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.accent
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Text(
                                size,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textDark,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Sticky Bottom Action Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã thêm sản phẩm vào giỏ hàng!'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                        label: const Text(
                          'Thêm vào giỏ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Chuyển đến màn hình thanh toán!'),
                              backgroundColor: AppColors.accent,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Mua ngay',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    String value = amount.round().toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return value.replaceAllMapped(reg, (Match match) => '${match[1]}.');
  }
}
