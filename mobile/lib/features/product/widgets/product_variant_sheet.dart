import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/product.dart';
import '../../../core/router/app_routes.dart';
import '../../cart/providers/cart_provider.dart';
import '../../../core/models/cart_model.dart';

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
    if (widget.product.colors.isNotEmpty) {
      selectedColor = widget.product.colors.first;
    }
    if (widget.product.sizes.isNotEmpty) {
      selectedSize = widget.product.sizes.first;
    }
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
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.product.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(width: 80, height: 80, color: Colors.grey[200]),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₫${widget.product.price.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          if (widget.product.colors.isNotEmpty) ...[
            const Text(AppStrings.color, style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: widget.product.colors.map((color) {
                final isSelected = selectedColor == color;
                return ChoiceChip(
                  label: Text(color),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      selectedColor = selected ? color : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          if (widget.product.sizes.isNotEmpty) ...[
            const Text(AppStrings.size, style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: widget.product.sizes.map((size) {
                final isSelected = selectedSize == size;
                return ChoiceChip(
                  label: Text(size),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      selectedSize = selected ? size : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(AppStrings.quantity, style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      if (quantity > 1) {
                        setState(() => quantity--);
                      }
                    },
                  ),
                  Text('$quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      setState(() => quantity++);
                    },
                  ),
                ],
              ),
            ],
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
