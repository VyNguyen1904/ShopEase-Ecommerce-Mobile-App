import sys
import re

file_path = r'd:\ShopEase-Ecommerce-Mobile-App\mobile\lib\features\seller\screens\seller_edit_product_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Rename classes
content = content.replace("SellerAddProductScreen", "SellerEditProductScreen")

# 2. Add product parameter
old_constructor = '''class SellerEditProductScreen extends ConsumerStatefulWidget {
  const SellerEditProductScreen({super.key});'''
new_constructor = '''class SellerEditProductScreen extends ConsumerStatefulWidget {
  final Product product;
  const SellerEditProductScreen({super.key, required this.product});'''
content = content.replace(old_constructor, new_constructor)

# 3. Add existing image URL and initState
old_state = '''  final _descController = TextEditingController();
  XFile? _selectedImageFile;
  Uint8List? _selectedImageBytes;
  final ImageService _imageService = ImageService();'''
new_state = '''  final _descController = TextEditingController();
  XFile? _selectedImageFile;
  Uint8List? _selectedImageBytes;
  String? _existingImageUrl;
  final ImageService _imageService = ImageService();'''
content = content.replace(old_state, new_state)

init_state = '''
  @override
  void initState() {
    super.initState();
    _nameController.text = widget.product.name;
    _priceController.text = widget.product.price.toInt().toString();
    _originalPriceController.text = widget.product.originalPrice?.toInt().toString() ?? '';
    _stockController.text = widget.product.stockQuantity.toString();
    _weightController.text = widget.product.weightKg.toString();
    _descController.text = widget.product.description;
    _selectedSizes.addAll(widget.product.sizes);
    _selectedColors.addAll(widget.product.colors);
    _existingImageUrl = widget.product.imageUrl;
    // We will set _selectedCategory in build once categories are loaded
  }
'''
content = content.replace('  @override\n  void dispose() {', init_state + '\n  @override\n  void dispose() {')

# 4. Save Product validation (allow no new image if existing exists)
old_save_check = '''    if (_selectedImageFile == null || _selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ảnh sản phẩm!')),
      );
      return;
    }'''
new_save_check = '''    if ((_selectedImageFile == null || _selectedImageBytes == null) && (_existingImageUrl == null || _existingImageUrl!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ảnh sản phẩm!')),
      );
      return;
    }'''
content = content.replace(old_save_check, new_save_check)

# 5. Image upload and updateProduct
old_upload = '''    try {
      String? uploadedImageUrl = await _imageService.uploadImage(_selectedImageBytes!, _selectedImageFile!.name);
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
      );

      final service = ref.read(productServiceProvider);
      await service.createProduct(newProduct);'''
new_upload = '''    try {
      String imageUrl = _existingImageUrl ?? '';
      if (_selectedImageFile != null && _selectedImageBytes != null) {
        String? uploadedImageUrl = await _imageService.uploadImage(_selectedImageBytes!, _selectedImageFile!.name);
        if (uploadedImageUrl == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Lỗi tải ảnh lên!')),
            );
            setState(() => _isLoading = false);
          }
          return;
        }
        imageUrl = uploadedImageUrl;
      }

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
      await service.updateProduct(widget.product.id, updatedProduct);'''
content = content.replace(old_upload, new_upload)

content = content.replace('AppStrings.addProductSuccess', "'Cập nhật sản phẩm thành công!'")
content = content.replace('AppStrings.addNewProduct', "'Cập nhật sản phẩm'")
content = content.replace('AppStrings.noProductsList', "'Không có sản phẩm nào'")

# 6. UI changes for image picking
old_ui_image = '''                child: _selectedImageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_photo_alternate_outlined, size: 48, color: AppColors.primary),
                          SizedBox(height: 8),
                          Text('Chọn ảnh sản phẩm', style: TextStyle(color: AppColors.textGrey)),
                        ],
                      ),'''
new_ui_image = '''                child: _selectedImageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
                      )
                    : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(_existingImageUrl!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add_photo_alternate_outlined, size: 48, color: AppColors.primary),
                              SizedBox(height: 8),
                              Text('Chọn ảnh sản phẩm', style: TextStyle(color: AppColors.textGrey)),
                            ],
                          ),'''
content = content.replace(old_ui_image, new_ui_image)

# 7. Preselect category in build method
old_build_start = '''  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);'''
new_build_start = '''  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    
    // Set initial category
    if (_selectedCategory == null && categoriesAsync.hasValue && categoriesAsync.value != null) {
      final cats = categoriesAsync.value!;
      final match = cats.where((c) => c.id == widget.product.category).toList();
      if (match.isNotEmpty) {
        _selectedCategory = match.first.name;
      }
    }'''
content = content.replace(old_build_start, new_build_start)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Rewrite for edit product successful!")
