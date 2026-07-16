import sys
import re

file_path = r'd:\ShopEase-Ecommerce-Mobile-App\mobile\lib\features\seller\screens\seller_add_product_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Imports
imports = '''import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/image_service.dart';
import '../../../core/utils/currency_formatter.dart';
'''
content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\n" + imports)

# 2. State vars
content = content.replace(
'''  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descController = TextEditingController();
  final _imageController = TextEditingController();''',
'''  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _weightController = TextEditingController();
  final _descController = TextEditingController();
  File? _selectedImageFile;
  final ImageService _imageService = ImageService();
  final ImagePicker _picker = ImagePicker();'''
)

# 3. Dispose
content = content.replace(
'''    _priceController.dispose();
    _stockController.dispose();
    _descController.dispose();
    _imageController.dispose();''',
'''    _priceController.dispose();
    _originalPriceController.dispose();
    _stockController.dispose();
    _weightController.dispose();
    _descController.dispose();'''
)

# 4. _pickImage method
pick_image_method = '''
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImageFile = File(image.path);
      });
    }
  }

  Future<void> _generateAiDescription() async {'''
content = content.replace('  Future<void> _generateAiDescription() async {', pick_image_method)

# 5. Ai service parsing fix
content = content.replace(
'''      final priceStr = _priceController.text.trim();
      final price = double.tryParse(priceStr) ?? 0.0;''',
'''      final priceStr = _priceController.text.trim();
      final price = double.tryParse(priceStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;'''
)

# 6. _saveProduct parsing
save_product_old = '''  Future<void> _saveProduct(List<CategoryModel> categories) async {
    final name = _nameController.text.trim();
    final priceStr = _priceController.text.trim();
    final stockStr = _stockController.text.trim();
    final desc = _descController.text.trim();
    final imageUrl = _imageController.text.trim();

    if (name.isEmpty || priceStr.isEmpty || stockStr.isEmpty || _selectedCategory == null || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.fillRequiredFields)),
      );
      return;
    }

    final price = double.tryParse(priceStr) ?? 0.0;
    final stock = int.tryParse(stockStr) ?? 0;'''

save_product_new = '''  Future<void> _saveProduct(List<CategoryModel> categories) async {
    final name = _nameController.text.trim();
    final priceStr = _priceController.text.trim();
    final origPriceStr = _originalPriceController.text.trim();
    final stockStr = _stockController.text.trim();
    final weightStr = _weightController.text.trim();
    final desc = _descController.text.trim();

    if (_selectedImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ảnh sản phẩm!')),
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
    final weightKg = double.tryParse(weightStr.replaceAll(',', '.')) ?? 0.0;'''
content = content.replace(save_product_old, save_product_new)

# 7. Add image upload and product creation
product_creation_old = '''    setState(() => _isLoading = true);

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
      );'''

product_creation_new = '''    setState(() => _isLoading = true);

    try {
      String? uploadedImageUrl = await _imageService.uploadImage(_selectedImageFile!);
      if (uploadedImageUrl == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lỗi tải ảnh lên!')),
          );
          setState(() => _isLoading = false);
        }
        return;
      }

      final newProduct = Product(
        id: '',
        name: name,
        category: selectedCatModel.id, // Must send categoryId
        price: price,
        originalPrice: originalPrice,
        imageUrl: uploadedImageUrl,
        rating: 0.0,
        reviewsCount: 0,
        salesCount: 0,
        sizes: _selectedSizes,
        colors: _selectedColors,
        description: desc,
        stockQuantity: stock,
        weightKg: weightKg,
      );'''
content = content.replace(product_creation_old, product_creation_new)

# 8. UI changes
ui_old = '''            SellerInputField(
              controller: _imageController,
              icon: Icons.image_outlined,
              label: AppStrings.productImageUrl,
              hintText: AppStrings.productImageHint,
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
              error: (err, _) => Text('${AppStrings.loadCategoryError}$err', style: const TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 16),
            SellerInputField(
              controller: _stockController,
              icon: Icons.inventory_2_outlined,
              label: AppStrings.stockQuantity,
              hintText: AppStrings.enterStockQuantity,
              keyboardType: TextInputType.number,
            ),'''

ui_new = '''            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _selectedImageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_selectedImageFile!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_photo_alternate_outlined, size: 48, color: AppColors.primary),
                          SizedBox(height: 8),
                          Text('Chọn ảnh sản phẩm', style: TextStyle(color: AppColors.textGrey)),
                        ],
                      ),
              ),
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
            ),'''
content = content.replace(ui_old, ui_new)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print('Rewrite successful!')
