import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/product_provider.dart';
import '../../../core/constants/app_strings.dart';
import 'price_range_filter.dart';
import 'minimum_rating_filter.dart';

class SearchFilterDrawer extends ConsumerStatefulWidget {
  const SearchFilterDrawer({super.key});

  @override
  ConsumerState<SearchFilterDrawer> createState() => _SearchFilterDrawerState();
}

class _SearchFilterDrawerState extends ConsumerState<SearchFilterDrawer> {
  // Local state for sliders so it doesn't rebuild main list while dragging
  double _tempMinPrice = 0;
  double _tempMaxPrice = 10000000;
  double _tempMinRating = 0;

  @override
  void initState() {
    super.initState();
    _initValues();
  }

  void _initValues() {
    _tempMinPrice = ref.read(minPriceProvider) ?? 0;
    _tempMaxPrice = ref.read(maxPriceProvider) ?? 10000000;
    _tempMinRating = ref.read(minRatingProvider) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    // Listen to changes from outside (e.g., if user clicks "Xóa lọc" on main screen)
    ref.listen(minPriceProvider, (_, next) {
      if (next == null) setState(() => _tempMinPrice = 0);
    });
    ref.listen(maxPriceProvider, (_, next) {
      if (next == null) setState(() => _tempMaxPrice = 10000000);
    });
    ref.listen(minRatingProvider, (_, next) {
      if (next == null) setState(() => _tempMinRating = 0);
    });

    final currentSortBy = ref.watch(sortByProvider);
    final currentSortDir = ref.watch(sortDirProvider);
    final currentKey = '${currentSortBy}_$currentSortDir';
    
    final currentCategory = ref.watch(selectedCategorySearchProvider);

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, color: AppColors.primary, size: 24),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      AppStrings.filterAndSort,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textGrey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildSectionHeader(Icons.swap_vert, AppStrings.sortByOptions),
                  _sortOption(AppStrings.defaultVariant, 'none_desc', currentKey),
                  _sortOption(AppStrings.nameAsc, 'name_asc', currentKey),
                  _sortOption(AppStrings.nameDesc, 'name_desc', currentKey),
                  _sortOption(AppStrings.priceAsc, 'price_asc', currentKey),
                  _sortOption(AppStrings.priceDesc, 'price_desc', currentKey),
                  _sortOption(AppStrings.highestRating, 'rating_desc', currentKey),
                  _sortOption(AppStrings.bestSelling, 'salesCount_desc', currentKey),
                  
                  const Divider(height: 32),

                  _buildSectionHeader(Icons.grid_view, AppStrings.navCategory),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Consumer(
                      builder: (context, innerRef, _) {
                        final categoriesAsync = innerRef.watch(categoriesProvider);
                        return categoriesAsync.when(
                          data: (categories) {
                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _categoryChip(AppStrings.all, currentCategory == null, () {
                                  ref.read(selectedCategorySearchProvider.notifier).state = null;
                                }),
                                ...categories.map((cat) {
                                  return _categoryChip(cat.name, currentCategory == cat.name, () {
                                    ref.read(selectedCategorySearchProvider.notifier).state = cat.name;
                                  });
                                }),
                              ],
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (_, _) => const Text(AppStrings.errorLoadCategory),
                        );
                      },
                    ),
                  ),

                  const Divider(height: 32),

                  _buildSectionHeader(Icons.local_offer_outlined, AppStrings.priceRange),
                  PriceRangeFilter(
                    minPrice: _tempMinPrice,
                    maxPrice: _tempMaxPrice,
                    formatCurrency: _formatCurrency,
                    onChanged: (values) {
                      setState(() {
                        _tempMinPrice = values.start;
                        _tempMaxPrice = values.end;
                      });
                    },
                  ),

                  const Divider(height: 32),

                  _buildSectionHeader(Icons.star_outline, AppStrings.minRating),
                  MinimumRatingFilter(
                    currentRating: _tempMinRating,
                    onChanged: (rating) {
                      setState(() {
                        _tempMinRating = rating;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(sortByProvider.notifier).state = 'none';
                        ref.read(sortDirProvider.notifier).state = 'desc';
                        ref.read(selectedCategorySearchProvider.notifier).state = null;
                        ref.read(minPriceProvider.notifier).state = null;
                        ref.read(maxPriceProvider.notifier).state = null;
                        ref.read(minRatingProvider.notifier).state = null;
                        setState(() {
                          _tempMinPrice = 0;
                          _tempMaxPrice = 10000000;
                          _tempMinRating = 0;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(AppStrings.resetFilter, style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Apply sliders state to providers
                        ref.read(minPriceProvider.notifier).state = _tempMinPrice > 0 ? _tempMinPrice : null;
                        ref.read(maxPriceProvider.notifier).state = _tempMaxPrice < 10000000 ? _tempMaxPrice : null;
                        ref.read(minRatingProvider.notifier).state = _tempMinRating > 0 ? _tempMinRating : null;
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text(AppStrings.apply, style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textGrey),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sortOption(String label, String value, String groupValue) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () {
        final parts = value.split('_');
        ref.read(sortByProvider.notifier).state = parts[0];
        ref.read(sortDirProvider.notifier).state = parts[1];
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 5 : 1.5,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip(String label, bool isSelected, VoidCallback onTap) {
    return ActionChip(
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 13,
        color: isSelected ? AppColors.primary : AppColors.textDark,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      backgroundColor: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.bgLight,
      side: BorderSide(
        color: isSelected ? AppColors.primary : Colors.transparent,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: onTap,
    );
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }
}
