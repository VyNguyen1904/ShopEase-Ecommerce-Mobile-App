import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/providers/product_provider.dart';
import '../../../core/models/product.dart';
import '../../../core/providers/auth_provider.dart';

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
    final userAsync = ref.watch(userProfileProvider);
    
    int totalCount = 0;
    int inStockCount = 0;
    int outOfStockCount = 0;
    
    final user = userAsync.valueOrNull;
    if (user != null) {
      final productsAsync = ref.watch(sellerProductsProvider(user.id));
      if (productsAsync.hasValue && productsAsync.value != null) {
        totalCount = productsAsync.value!.length;
        // Hiện tại model Product chưa có field stock, nên tạm tính là tất cả đều còn hàng
        inStockCount = totalCount;
        outOfStockCount = 0;
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
          'Sản phẩm',
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
                bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
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
                Tab(text: 'Tất cả ($totalCount)'),
                Tab(text: 'Còn hàng ($inStockCount)'),
                Tab(text: 'Hết hàng ($outOfStockCount)'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductList(),
          _buildProductList(),
          _buildProductList(),
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
              'Thêm sản phẩm',
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

  Widget _buildProductList() {
    final userAsync = ref.watch(userProfileProvider);
    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Center(child: Text('Vui lòng đăng nhập'));
        }
        return ref.watch(sellerProductsProvider(user.id)).when(
          data: (products) {
            if (products.isEmpty) {
              return const Center(child: Text('Chưa có sản phẩm nào.'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: products.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey.withValues(alpha: 0.1),
                height: 32,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductItem(product);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Lỗi: $err')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Lỗi: $err')),
    );
  }

  Widget _buildProductItem(Product product) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${product.price.toInt().toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")} đ',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.category,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.delete_outline,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }
}
