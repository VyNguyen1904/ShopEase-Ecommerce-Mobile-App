import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/product.dart';
import '../../../core/providers/product_provider.dart';
import '../../../core/providers/selected_product_provider.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/product_card.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  ConsumerState<SearchResultsScreen> createState() =>
      _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final searchQuery = _searchController.text;
    final searchAsyncValue = ref.watch(filteredSearchProductsProvider(searchQuery));

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Search input header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textDark,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textDark,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: IconButton(
                            icon: const Icon(
                              Icons.search,
                              color: AppColors.textGrey,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {});
                            },
                          ),
                          hintText: 'Tìm kiếm sản phẩm...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        textInputAction: TextInputAction.search,
                        onSubmitted: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                    child: const ClipOval(
                      child: Icon(Icons.person, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Filter Buttons
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterButton(icon: Icons.swap_vert, label: 'Sắp xếp'),
                  const SizedBox(width: 10),
                  _buildFilterButton(icon: Icons.grid_view, label: 'Danh mục'),
                  const SizedBox(width: 10),
                  _buildFilterButton(
                    icon: Icons.local_offer_outlined,
                    label: 'Giá',
                    isActive: ref.watch(sortOrderProvider) != 'none',
                    onTap: () => _showSortOptions(context, ref),
                  ),
                  const SizedBox(width: 10),
                  _buildFilterButton(
                    icon: Icons.filter_alt_outlined,
                    label: 'Bộ lọc',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Results count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: searchAsyncValue.when(
                data: (products) => RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 15, color: AppColors.textGrey),
                    children: [
                      TextSpan(
                        text: '${products.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const TextSpan(text: ' kết quả tìm thấy'),
                    ],
                  ),
                ),
                loading: () => const SizedBox(),
                error: (_, _s) => const SizedBox(),
              ),
            ),
            const SizedBox(height: 12),

            // 4. Products List
            Expanded(
              child: searchAsyncValue.when(
                data: (products) {
                  if (products.isEmpty) {
                    return const Center(child: Text('Không tìm thấy sản phẩm nào.'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final heroTag = 'hero_search_${product.id}';
                      return ProductCard(
                        product: product,
                        isHorizontal: true,
                        heroTag: heroTag,
                        onTap: () {
                          ref.read(selectedProductProvider.notifier).state = product;
                          ref.read(selectedHeroTagProvider.notifier).state = heroTag;
                          context.push(AppRoutes.productDetailPath(product.id));
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Lỗi: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tính năng "$label" đang được phát triển'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppColors.primary : AppColors.textDark,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.primary : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortOptions(BuildContext context, WidgetRef ref) {
    final currentSort = ref.read(sortOrderProvider);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sắp xếp theo giá',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Mặc định'),
                trailing: currentSort == 'none' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  ref.read(sortOrderProvider.notifier).state = 'none';
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Giá: Từ thấp đến cao'),
                trailing: currentSort == 'asc' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  ref.read(sortOrderProvider.notifier).state = 'asc';
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Giá: Từ cao xuống thấp'),
                trailing: currentSort == 'desc' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  ref.read(sortOrderProvider.notifier).state = 'desc';
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
