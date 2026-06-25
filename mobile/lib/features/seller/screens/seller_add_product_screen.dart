import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/product_provider.dart';
import '../../../core/models/product.dart';
import '../../../core/models/category_model.dart';
import '../widgets/seller_input_field.dart';
import '../widgets/seller_dropdown_field.dart';

class SellerAddProductScreen extends ConsumerStatefulWidget {
  const SellerAddProductScreen({super.key});

  @override
  ConsumerState<SellerAddProductScreen> createState() => _SellerAddProductScreenState();
}

class _SellerAddProductScreenState extends ConsumerState<SellerAddProductScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descController = TextEditingController();
  final _imageController = TextEditingController();
  String? _selectedCategory;
  bool _isLoading = false;

  final List<String> _availableSizes = ['S', 'M', 'L', 'XL', 'XXL', 'Freesize'];
  final List<String> _availableColors = ['Đen', 'Trắng', 'Đỏ', 'Xanh dương', 'Xanh lá', 'Vàng', 'Hồng', 'Xám', 'Nâu'];
  
  final List<String> _selectedSizes = [];
  final List<String> _selectedColors = [];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct(List<CategoryModel> categories) async {
    final name = _nameController.text.trim();
    final priceStr = _priceController.text.trim();
    final stockStr = _stockController.text.trim();
    final desc = _descController.text.trim();
    final imageUrl = _imageController.text.trim();

    if (name.isEmpty || priceStr.isEmpty || _selectedCategory == null || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin bắt buộc.')),
      );
      return;
    }

    final price = double.tryParse(priceStr) ?? 0.0;
    final stock = int.tryParse(stockStr) ?? 0;
    
    // Find category ID
    final selectedCatModel = categories.firstWhere(
      (c) => c.name == _selectedCategory,
      orElse: () => categories.first,
    );

    setState(() => _isLoading = true);

    try {
      final newProduct = Product(
        id: '',
        name: name,
        category: selectedCatModel.id, // Must send categoryId
        price: price,
        imageUrl: imageUrl.isNotEmpty ? imageUrl : 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
        rating: 0.0,
        reviewsCount: 0,
        salesCount: 0,
        sizes: _selectedSizes,
        colors: _selectedColors,
        description: desc,
        stockQuantity: stock,
      );

      final service = ref.read(productServiceProvider);
      await service.createProduct(newProduct);
      
      ref.invalidate(sellerProductsProvider);
      ref.invalidate(productsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm sản phẩm thành công!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.errorPrefix}$e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          AppStrings.addNewProduct,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SellerInputField(
              controller: _imageController,
              icon: Icons.image_outlined,
              label: 'URL Ảnh sản phẩm',
              hintText: 'Nhập đường dẫn ảnh (http://...)',
            ),
            const SizedBox(height: 32),
            const Text(
              AppStrings.productInfo,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            SellerInputField(
              controller: _nameController,
              icon: Icons.shopping_bag_outlined,
              label: AppStrings.productName,
              hintText: AppStrings.enterProductName,
            ),
            const SizedBox(height: 16),
            SellerInputField(
              controller: _priceController,
              icon: Icons.local_offer_outlined,
              label: AppStrings.sellingPrice,
              hintText: AppStrings.enterPrice,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            categoriesAsync.when(
              data: (categories) => SellerDropdownField(
                icon: Icons.grid_view,
                label: AppStrings.category,
                hintText: AppStrings.selectCategory,
                items: categories.map((e) => e.name).toList(),
                value: _selectedCategory,
                onChanged: (val) {
                  setState(() {
                    _selectedCategory = val;
                  });
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Lỗi tải danh mục: $err', style: const TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 16),
            SellerInputField(
              controller: _stockController,
              icon: Icons.inventory_2_outlined,
              label: AppStrings.stockQuantity,
              hintText: AppStrings.enterStockQuantity,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildMultiSelectField(
              icon: Icons.straighten_outlined,
              label: 'Kích cỡ (Sizes)',
              options: _availableSizes,
              selectedOptions: _selectedSizes,
            ),
            const SizedBox(height: 16),
            _buildMultiSelectField(
              icon: Icons.color_lens_outlined,
              label: 'Màu sắc (Colors)',
              options: _availableColors,
              selectedOptions: _selectedColors,
            ),
            const SizedBox(height: 16),
            SellerInputField(
              controller: _descController,
              icon: Icons.description_outlined,
              label: AppStrings.productDescTitle,
              hintText: AppStrings.enterProductDesc,
              maxLines: 5,
            ),
          ],
        ),
      ),
      bottomNavigationBar: categoriesAsync.maybeWhen(
        data: (categories) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _saveProduct(categories),
              icon: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save_outlined, color: Colors.white),
              label: Text(
                _isLoading ? 'Đang lưu...' : AppStrings.saveProduct,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent, // Orange color
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildMultiSelectField({
    required IconData icon,
    required String label,
    required List<String> options,
    required List<String> selectedOptions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedOptions.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    selectedOptions.add(option);
                  } else {
                    selectedOptions.remove(option);
                  }
                });
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textDark,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : Colors.grey.withValues(alpha: 0.3),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
