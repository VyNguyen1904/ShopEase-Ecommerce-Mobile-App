import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers/selected_product_provider.dart';

class ProductOptionsSelector extends ConsumerStatefulWidget {
  final List<String> sizes;
  final List<String> colors;

  const ProductOptionsSelector({
    super.key, 
    required this.sizes,
    required this.colors,
  });

  @override
  ConsumerState<ProductOptionsSelector> createState() => _ProductOptionsSelectorState();
}

class _ProductOptionsSelectorState extends ConsumerState<ProductOptionsSelector> {
  final int _selectedColorIndex = 1;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.colors.isNotEmpty) {
        ref.read(selectedProductColorProvider.notifier).state = widget.colors.first;
      } else {
        ref.read(selectedProductColorProvider.notifier).state = null;
      }
      if (widget.sizes.isNotEmpty) {
        ref.read(selectedProductSizeProvider.notifier).state = widget.sizes.first;
      } else {
        ref.read(selectedProductSizeProvider.notifier).state = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = ref.watch(selectedProductColorProvider);
    final selectedSize = ref.watch(selectedProductSizeProvider);

    if (widget.colors.isEmpty && widget.sizes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.colors.isNotEmpty) ...[
          Text(
            '${AppStrings.colorPrefix}${selectedColor ?? ''}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.colors.map((color) {
                final isSelected = selectedColor == color;
                return GestureDetector(
                  onTap: () {
                    ref.read(selectedProductColorProvider.notifier).state = color;
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accent : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected ? AppColors.accent : AppColors.border,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      color,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.textDark,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (widget.sizes.isNotEmpty) ...[
        const Text(
          AppStrings.size,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: widget.sizes.map((size) {
              final isSelected = selectedSize == size;
              return GestureDetector(
                onTap: () {
                  ref.read(selectedProductSizeProvider.notifier).state = size;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.only(right: 12),
                  padding: EdgeInsets.symmetric(horizontal: size.length > 3 ? 16.0 : 0.0),
                  constraints: BoxConstraints(
                    minWidth: isSelected ? 48 : 42,
                    minHeight: isSelected ? 48 : 42,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected ? AppColors.accent : AppColors.border,
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    size,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textDark,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 32),
        ]
      ],
    );
  }
}
