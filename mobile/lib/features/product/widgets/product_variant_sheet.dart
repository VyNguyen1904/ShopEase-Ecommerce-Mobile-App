import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/product.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../core/models/cart_model.dart';
import '../../../core/providers/selected_product_provider.dart';
import 'variant_selection_group.dart';
import 'product_sheet_header.dart';
import 'quantity_selector.dart';

class ProductVariantSheet extends ConsumerStatefulWidget {
  final Product product;
  final bool isBuyNow;

  const ProductVariantSheet({
    super.key,
    required this.product,
    this.isBuyNow = false,
  });

  @override
  ConsumerState<ProductVariantSheet> createState() => _ProductVariantSheetState();
}

class _ProductVariantSheetState extends ConsumerState<ProductVariantSheet> {
  String? selectedColor;
  String? selectedSize;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        selectedColor = ref.read(selectedProductColorProvider);
        selectedSize = ref.read(selectedProductSizeProvider);
        
        // Fallback if providers are empty
        if (selectedColor == null && widget.product.colors.isNotEmpty) {
          selectedColor = widget.product.colors.first;
        }
        if (selectedSize == null && widget.product.sizes.isNotEmpty) {
          selectedSize = widget.product.sizes.first;
        }
      });
    });
  }

  void _confirm() {
    if (widget.product.colors.isNotEmpty && selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.selectColorError)),
      );
      return;
    }
    if (widget.product.sizes.isNotEmpty && selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.selectSizeError)),
      );
      return;
    }

    if (widget.isBuyNow) {
      final directItem = CartItem(
        itemId: 'direct_buy',
        productId: int.parse(widget.product.id),
        price: widget.product.price,
        quantity: quantity,
        subtotal: widget.product.price * quantity,
        color: selectedColor,
        size: selectedSize,
        productName: widget.product.name,
        productImageUrl: widget.product.imageUrl,
        productVariant: [selectedColor, selectedSize].where((e) => e != null).join(', '),
      );
      
      Navigator.of(context).pop();
      context.push(AppRoutes.checkout, extra: {'directItems': [directItem]});
    } else {
      ref.read(cartProvider.notifier).addToCart(
        int.parse(widget.product.id),
        quantity,
        color: selectedColor,
        size: selectedSize,
      ).then((_) {
        Navigator.of(context).pop();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.addedToCart)),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        16, 
        0, 
        16, 
        MediaQuery.of(context).padding.bottom + 16,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductSheetHeader(
            imageUrl: widget.product.imageUrl,
            name: widget.product.name,
            price: widget.product.price,
          ),
          const Divider(height: 32),
          VariantSelectionGroup(
            title: AppStrings.color,
            items: widget.product.colors,
            selectedItem: selectedColor,
            onSelected: (selected) {
              setState(() {
                selectedColor = selected;
              });
              ref.read(selectedProductColorProvider.notifier).state = selectedColor;
            },
          ),
          VariantSelectionGroup(
            title: AppStrings.size,
            items: widget.product.sizes,
            selectedItem: selectedSize,
            onSelected: (selected) {
              setState(() {
                selectedSize = selected;
              });
              ref.read(selectedProductSizeProvider.notifier).state = selectedSize;
            },
          ),
          QuantitySelector(
            quantity: quantity,
            onDecrease: () {
              if (quantity > 1) {
                setState(() => quantity--);
              }
            },
            onIncrease: () {
              setState(() => quantity++);
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _confirm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: widget.isBuyNow ? Colors.red : Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text(widget.isBuyNow ? AppStrings.buyNow : AppStrings.addToCart),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
