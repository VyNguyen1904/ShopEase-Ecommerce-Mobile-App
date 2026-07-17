import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/providers/product_provider.dart';
import '../../../core/models/product.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/constants/app_strings.dart';
import '../widgets/seller_product_card.dart';
import '../../../core/providers/notification_provider.dart';

class SellerProductsScreen extends ConsumerStatefulWidget {
  const SellerProductsScreen({super.key});

  @override
  ConsumerState<SellerProductsScreen> createState() => _SellerProductsScreenState();
}

class _SellerProductsScreenState extends ConsumerState<SellerProductsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock removed

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure WebSocket is active for real-time updates
    ref.watch(notificationListProvider);
    
    final userAsync = ref.watch(userProfileProvider);
    
    int totalCount = 0;
    int inStockCount = 0;
    int outOfStockCount = 0;
    
    final user = userAsync.valueOrNull;
    if (user != null) {
      final productsAsync = ref.watch(sellerProductsProvider(user.id));
      if (productsAsync.hasValue && productsAsync.value != null) {
        final products = productsAsync.value!;
        totalCount = products.length;
        inStockCount = products.where((p) => p.stockQuantity > 0).length;
        outOfStockCount = totalCount - inStockCount;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          AppStrings.products,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textGrey,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
              tabs: [
                Tab(text: '${AppStrings.all} ($totalCount)'),
                Tab(text: '${AppStrings.inStock} ($inStockCount)'),
                Tab(text: '${AppStrings.outOfStock} ($outOfStockCount)'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductList(0),
          _buildProductList(1),
          _buildProductList(2),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton.icon(
            onPressed: () {
              context.push(AppRoutes.sellerAddProduct);
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              AppStrings.addProduct,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductList(int tabIndex) {
    final userAsync = ref.watch(userProfileProvider);
    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Center(child: Text(AppStrings.pleaseLogin));
        }
        return ref.watch(sellerProductsProvider(user.id)).when(
          data: (allProducts) {
            final products = allProducts.where((p) {
              if (tabIndex == 1) return p.stockQuantity > 0;
              if (tabIndex == 2) return p.stockQuantity <= 0;
              return true;
            }).toList();

            if (products.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(sellerProductsProvider(user.id));
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                    const Center(child: Text(AppStrings.noProductsList)),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(sellerProductsProvider(user.id));
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: products.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey.withValues(alpha: 0.1),
                  height: 32,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return SellerProductCard(
                    product: product,
                    onEdit: () {
                      context.push(AppRoutes.sellerEditProduct, extra: product);
                    },
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('${AppStrings.errorPrefix}$err')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('${AppStrings.errorPrefix}$err')),
    );
  }

}
