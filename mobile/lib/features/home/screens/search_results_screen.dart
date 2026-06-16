import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/product.dart';
import '../../../core/providers/product_provider.dart';
import '../../../core/providers/selected_product_provider.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/product_card.dart';
import '../widgets/search_filter_drawer.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  ConsumerState<SearchResultsScreen> createState() =>
      _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  final TextEditingController _searchController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = _searchController.text;
    final searchAsyncValue =
        ref.watch(filteredSearchProductsProvider(searchQuery));
    final selectedCategory = ref.watch(selectedCategorySearchProvider);
    final sortBy = ref.watch(sortByProvider);
    final filterCount = ref.watch(activeFilterCountProvider);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const SearchFilterDrawer(),
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
                    onTap: () {
                      _clearAllFilters();
                      context.pop();
                    },
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
                        onChanged: (value) {
                          setState(() {});
                        },
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
                  _buildFilterButton(
                    icon: Icons.swap_vert,
                    label: 'Sắp xếp',
                    isActive: sortBy != 'none',
                    onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  const SizedBox(width: 10),
                  _buildFilterButton(
                    icon: Icons.grid_view,
                    label: selectedCategory ?? 'Danh mục',
                    isActive: selectedCategory != null,
                    onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  const SizedBox(width: 10),
                  _buildFilterButton(
                    icon: Icons.local_offer_outlined,
                    label: 'Giá',
                    isActive: ref.watch(sortOrderProvider) != 'none',
                    onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  const SizedBox(width: 10),
                  _buildFilterButton(
                    icon: Icons.filter_alt_outlined,
                    label: 'Bộ lọc',
                    isActive: _hasAdvancedFilters(),
                    badgeCount: filterCount,
                    onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Results count + active filter chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: searchAsyncValue.when(
                data: (products) => Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              fontSize: 15, color: AppColors.textGrey),
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
                    ),
                    if (filterCount > 0)
                      GestureDetector(
                        onTap: _clearAllFilters,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.alertRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.clear_all,
                                  size: 14, color: AppColors.alertRed),
                              SizedBox(width: 4),
                              Text(
                                'Xóa lọc',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.alertRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
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
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 64, color: AppColors.textLight),
                          const SizedBox(height: 16),
                          const Text(
                            'Không tìm thấy sản phẩm nào.',
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 16,
                            ),
                          ),
                          if (filterCount > 0) ...[
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _clearAllFilters,
                              child: const Text('Xóa bộ lọc'),
                            ),
                          ],
                        ],
                      ),
                    );
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
                          ref.read(selectedProductProvider.notifier).state =
                              product;
                          ref.read(selectedHeroTagProvider.notifier).state =
                              heroTag;
                          context.push(
                              AppRoutes.productDetailPath(product.id));
                        },
                      );
                    },
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, stack) =>
                    Center(child: Text('Lỗi: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────
  //  Helpers
  // ────────────────────────────────────────────────────

  bool _hasAdvancedFilters() {
    return ref.read(minPriceProvider) != null ||
        ref.read(maxPriceProvider) != null ||
        ref.read(minRatingProvider) != null;
  }

  void _clearAllFilters() {
    ref.read(sortByProvider.notifier).state = 'none';
    ref.read(sortDirProvider.notifier).state = 'desc';
    ref.read(sortOrderProvider.notifier).state = 'none';
    ref.read(selectedCategorySearchProvider.notifier).state = null;
    ref.read(minPriceProvider.notifier).state = null;
    ref.read(maxPriceProvider.notifier).state = null;
    ref.read(minRatingProvider.notifier).state = null;
  }

  Widget _buildFilterButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    int badgeCount = 0,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
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
            if (badgeCount > 0 && isActive) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
