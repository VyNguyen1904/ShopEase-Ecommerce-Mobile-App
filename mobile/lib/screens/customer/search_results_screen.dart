import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';

class SearchResultsScreen extends StatefulWidget {
  final VoidCallback onBack;
  final Function(Product product, String heroTag) onProductTap;

  const SearchResultsScreen({
    super.key,
    required this.onBack,
    required this.onProductTap,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final TextEditingController _searchController = TextEditingController(text: 'sneakers');

  @override
  Widget build(BuildContext context) {
    // Filter out only shoe category products for realistic mockup
    final List<Product> shoes = mockProducts.where((p) => p.category.contains('Giày')).toList();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Search input header with Back Arrow and Profile Pic (Customer/6.png)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: widget.onBack,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.arrow_back, color: AppColors.textDark, size: 24),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Search Bar Input
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
                        style: const TextStyle(fontSize: 15, color: AppColors.textDark),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search, color: AppColors.textGrey, size: 20),
                          hintText: 'Tìm kiếm sản phẩm...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // User Profile circular image
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

            // 2. Filter Buttons Row (Sắp xếp, Danh mục, Giá, Bộ lọc)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterButton(
                    icon: Icons.swap_vert,
                    label: 'Sắp xếp',
                  ),
                  const SizedBox(width: 10),
                  _buildFilterButton(
                    icon: Icons.grid_view,
                    label: 'Danh mục',
                  ),
                  const SizedBox(width: 10),
                  _buildFilterButton(
                    icon: Icons.local_offer_outlined,
                    label: 'Giá',
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

            // 3. Results count label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 15, color: AppColors.textGrey),
                  children: [
                    TextSpan(
                      text: '123',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    TextSpan(text: ' kết quả tìm thấy'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 4. Products List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: shoes.length,
                itemBuilder: (context, index) {
                  final product = shoes[index];
                  final heroTag = 'hero_search_${product.id}';
                  return ProductCard(
                    product: product,
                    isHorizontal: true,
                    heroTag: heroTag,
                    onTap: () => widget.onProductTap(product, heroTag),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textDark),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
