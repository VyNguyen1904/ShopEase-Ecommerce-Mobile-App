import sys

file_path = r'd:\ShopEase-Ecommerce-Mobile-App\mobile\lib\features\seller\screens\seller_add_product_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Imports
content = content.replace("import 'dart:io';", "import 'dart:typed_data';")

# 2. State vars
content = content.replace("File? _selectedImageFile;", "XFile? _selectedImageFile;\n  Uint8List? _selectedImageBytes;")

# 3. _pickImage method
old_pick = '''  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImageFile = File(image.path);
      });
    }
  }'''
new_pick = '''  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImageFile = image;
        _selectedImageBytes = bytes;
      });
    }
  }'''
content = content.replace(old_pick, new_pick)

# 4. _saveProduct check
old_check = '''    if (_selectedImageFile == null) {'''
new_check = '''    if (_selectedImageFile == null || _selectedImageBytes == null) {'''
content = content.replace(old_check, new_check)

# 5. ImageService upload
old_upload = '''String? uploadedImageUrl = await _imageService.uploadImage(_selectedImageFile!);'''
new_upload = '''String? uploadedImageUrl = await _imageService.uploadImage(_selectedImageBytes!, _selectedImageFile!.name);'''
content = content.replace(old_upload, new_upload)

# 6. Build method image display
old_image = '''child: Image.file(_selectedImageFile!, fit: BoxFit.cover),'''
new_image = '''child: Image.memory(_selectedImageBytes!, fit: BoxFit.cover),'''
content = content.replace(old_image, new_image)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated successfully!")
