import 'package:flutter/material.dart';
import '../../../core/utils/currency_formatter.dart';

import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/product_provider.dart';
import '../../../core/models/product.dart';
import '../../../core/models/category_model.dart';
import '../../../core/services/ai_service.dart';
import '../widgets/seller_input_field.dart';
import '../widgets/seller_dropdown_field.dart';
import '../widgets/multi_select_field.dart';
import '../widgets/save_product_button.dart';

class SellerEditProductScreen extends ConsumerStatefulWidget {
  final Product product;
  const SellerEditProductScreen({super.key, required this.product});

  @override
  ConsumerState<SellerEditProductScreen> createState() => _SellerEditProductScreenState();
}

class _SellerEditProductScreenState extends ConsumerState<SellerEditProductScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _weightController = TextEditingController();
  final _descController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String? _selectedCategory;
  bool _isLoading = false;
  bool _isGeneratingAi = false;
  final AiService _aiService = AiService();

  final List<String> _availableSizes = ['S', 'M', 'L', 'XL', 'XXL', 'Freesize'];
  final List<String> _availableColors = ['Đen', 'Trắng', 'Đỏ', 'Xanh dương', 'Xanh lá', 'Vàng', 'Hồng', 'Xám', 'Nâu'];
  
  final List<String> _selectedSizes = [];
  final List<String> _selectedColors = [];


  @override
  void initState() {
    super.initState();
    _nameController.text = widget.product.name;
    _priceController.text = widget.product.price.toInt().toString();
    _originalPriceController.text = widget.product.originalPrice?.toInt().toString() ?? '';
    _stockController.text = widget.product.stockQuantity.toString();
    _weightController.text = widget.product.weightKg.toString();
    _descController.text = widget.product.description;
    _imageUrlController.text = widget.product.imageUrl;
    _selectedSizes.addAll(widget.product.sizes);
    _selectedColors.addAll(widget.product.colors);
    // We will set _selectedCategory in build once categories are loaded
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _stockController.dispose();
    _weightController.dispose();
    _descController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _generateAiDescription() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên sản phẩm trước!')),
      );
      return;
    }

    setState(() => _isGeneratingAi = true);
    
    try {
      final priceStr = _priceController.text.trim();
      final price = double.tryParse(priceStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
      
      final description = await _aiService.generateProductDescription(
        name: name,
        category: _selectedCategory ?? '',
        price: price,
        sizes: _selectedSizes,
        colors: _selectedColors,
      );
      
      if (mounted) {
        _descController.text = description;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingAi = false);
      }
    }
  }

  Future<void> _saveProduct(List<CategoryModel> categories) async {
    final name = _nameController.text.trim();
    final priceStr = _priceController.text.trim();
    final origPriceStr = _originalPriceController.text.trim();
    final stockStr = _stockController.text.trim();
    final weightStr = _weightController.text.trim();
    final desc = _descController.text.trim();
    final imageUrl = _imageUrlController.text.trim();

    if (imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập URL ảnh sản phẩm!')),
      );
      return;
    }

    if (name.isEmpty || priceStr.isEmpty || stockStr.isEmpty || _selectedCategory == null || desc.isEmpty || weightStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.fillRequiredFields)),
      );
      return;
    }

    final price = double.tryParse(priceStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
    final originalPrice = origPriceStr.isNotEmpty ? double.tryParse(origPriceStr.replaceAll(RegExp(r'[^0-9]'), '')) : null;
    final stock = int.tryParse(stockStr) ?? 0;
    final weightKg = double.tryParse(weightStr.replaceAll(',', '.')) ?? 0.0;
    
    // Find category ID
    final selectedCatModel = categories.firstWhere(
      (c) => c.name == _selectedCategory,
      orElse: () => categories.first,
    );

    setState(() => _isLoading = true);

    try {
      final updatedProduct = Product(
        id: widget.product.id,
        name: name,
        category: selectedCatModel.id,
        price: price,
        originalPrice: originalPrice,
        imageUrl: imageUrl,
        rating: widget.product.rating,
        reviewsCount: widget.product.reviewsCount,
        salesCount: widget.product.salesCount,
        sizes: _selectedSizes,
        colors: _selectedColors,
        description: desc,
        stockQuantity: stock,
        weightKg: weightKg,
      );

      final service = ref.read(productServiceProvider);
      await service.updateProduct(widget.product.id, updatedProduct);
      
      ref.invalidate(sellerProductsProvider);
      ref.invalidate(productsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật sản phẩm thành công!')),
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
    
    // Set initial category
    if (_selectedCategory == null && categoriesAsync.hasValue && categoriesAsync.value != null) {
      final cats = categoriesAsync.value!;
      final match = cats.where((c) => c.id == widget.product.category).toList();
      if (match.isNotEmpty) {
        _selectedCategory = match.first.name;
      }
    }

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
          'Cập nhật sản phẩm',
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
              controller: _imageUrlController,
              icon: Icons.link_outlined,
              label: 'URL Ảnh sản phẩm',
              hintText: 'Nhập URL hình ảnh (vd: https://...)',
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
            Row(
              children: [
                Expanded(
                  child: SellerInputField(
                    controller: _priceController,
                    icon: Icons.local_offer_outlined,
                    label: AppStrings.sellingPrice,
                    hintText: AppStrings.enterPrice,
                    keyboardType: TextInputType.number,
                    inputFormatters: [CurrencyInputFormatter()],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SellerInputField(
                    controller: _originalPriceController,
                    icon: Icons.money_off_csred_outlined,
                    label: 'Giá gốc',
                    hintText: 'Tùy chọn',
                    keyboardType: TextInputType.number,
                    inputFormatters: [CurrencyInputFormatter()],
                  ),
                ),
              ],
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
              error: (err, _) => Text('${AppStrings.loadCategoryError}$err', style: const TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SellerInputField(
                    controller: _stockController,
                    icon: Icons.inventory_2_outlined,
                    label: AppStrings.stockQuantity,
                    hintText: AppStrings.enterStockQuantity,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SellerInputField(
                    controller: _weightController,
                    icon: Icons.scale_outlined,
                    label: 'Khối lượng (Kg)',
                    hintText: 'Ví dụ: 0.5',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            MultiSelectField(
              icon: Icons.straighten_outlined,
              label: AppStrings.sizesLabel,
              options: _availableSizes,
              selectedOptions: _selectedSizes,
              onSelectionChanged: (option, selected) {
                setState(() {
                  if (selected) {
                    _selectedSizes.add(option);
                  } else {
                    _selectedSizes.remove(option);
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            MultiSelectField(
              icon: Icons.color_lens_outlined,
              label: AppStrings.colorsLabel,
              options: _availableColors,
              selectedOptions: _selectedColors,
              onSelectionChanged: (option, selected) {
                setState(() {
                  if (selected) {
                    _selectedColors.add(option);
                  } else {
                    _selectedColors.remove(option);
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            SellerInputField(
              controller: _descController,
              icon: Icons.description_outlined,
              label: AppStrings.productDescTitle,
              hintText: AppStrings.enterProductDesc,
              maxLines: 5,
              trailingLabelWidget: _isGeneratingAi
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : TextButton.icon(
                      onPressed: _generateAiDescription,
                      icon: const Icon(Icons.auto_awesome, color: Colors.purple, size: 20),
                      label: const Text(
                        'AI',
                        style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: Colors.purple.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: categoriesAsync.maybeWhen(
        data: (categories) => SaveProductButton(
          isLoading: _isLoading,
          onPressed: () => _saveProduct(categories),
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

}
