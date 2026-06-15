import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/providers/selected_product_provider.dart';
import '../../../core/models/product.dart';

import '../widgets/product_options_selector.dart';
import '../widgets/product_bottom_bar.dart';
import '../widgets/product_header.dart';
import '../widgets/product_image.dart';
import '../widgets/product_info.dart';
import '../widgets/product_attributes.dart';
import '../widgets/product_reviews.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final product = ref.watch(selectedProductProvider);
    final heroTag = ref.watch(selectedHeroTagProvider);

    if (product == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.textLight,
              ),
              const SizedBox(height: 12),
              const Text('Không tìm thấy sản phẩm'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppRoutes.home);
                  }
                },
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            ProductHeader(
              isFavorite: _isFavorite,
              onFavoriteToggle: () {
                setState(() {
                  _isFavorite = !_isFavorite;
                });
              },
            ),
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ProductImage(
                        imageUrl: product.imageUrl,
                        heroTag: heroTag.isNotEmpty ? heroTag : 'hero_img_${product.id}_v',
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProductInfo(product: product),
                            ProductOptionsSelector(sizes: product.sizes),
                            const SizedBox(height: 24),
                            ProductAttributes(product: product),
                            const SizedBox(height: 24),
                            ProductReviews(productId: product.id),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ProductBottomBar(product: product),
          ],
        ),
      ),
    );
  }
}
