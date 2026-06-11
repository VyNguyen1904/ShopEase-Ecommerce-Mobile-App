import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/models/address_model.dart';

class AddressModal extends ConsumerStatefulWidget {
  final dynamic address; // Pass an address to edit, or null to create

  const AddressModal({super.key, this.address});

  @override
  ConsumerState<AddressModal> createState() => _AddressModalState();
}

class _AddressModalState extends ConsumerState<AddressModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _streetController;
  
  bool _isDefault = false;
  bool _isLoading = false;

  List<dynamic> _provinces = [];
  List<dynamic> _districts = [];
  dynamic _selectedProvince;
  dynamic _selectedDistrict;

  @override
  void initState() {
    super.initState();
    final addr = widget.address;
    _nameController = TextEditingController(text: addr?.name ?? '');
    _phoneController = TextEditingController(text: addr?.phone ?? '');
    _streetController = TextEditingController(text: addr?.address1 ?? '');
    _isDefault = addr?.isDefault ?? false;

    _fetchProvinces();
  }

  Future<void> _fetchProvinces() async {
    try {
      final response = await Dio().get('https://provinces.open-api.vn/api/p/');
      if (mounted) {
        setState(() {
          _provinces = response.data;
          // Try to select initial province if editing
          final addrCity = widget.address?.address2;
          if (addrCity != null && addrCity.isNotEmpty) {
            try {
              _selectedProvince = _provinces.firstWhere(
                (p) => addrCity.contains(p['name']),
              );
              if (_selectedProvince != null) {
                _fetchDistricts(_selectedProvince['code']);
              }
            } catch (e) {
              // Not found
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching provinces: $e');
    }
  }

  Future<void> _fetchDistricts(int provinceCode) async {
    try {
      final response = await Dio().get('https://provinces.open-api.vn/api/p/$provinceCode?depth=2');
      if (mounted) {
        setState(() {
          _districts = response.data['districts'];
          // Try to select initial district if editing
          final addrDistrict = widget.address?.address2;
          if (addrDistrict != null && addrDistrict.isNotEmpty) {
            try {
              _selectedDistrict = _districts.firstWhere(
                (d) => addrDistrict.contains(d['name']),
              );
            } catch (e) {
              // Not found
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching districts: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final addressData = AddressModel(
      id: widget.address?.id,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address1: _streetController.text.trim(),
      address2: '${_selectedDistrict?['name'] ?? ''}, ${_selectedProvince?['name'] ?? ''}',
      isDefault: _isDefault,
    );

    try {
      final authService = ref.read(authServiceProvider);
      if (widget.address == null) {
        await authService.addAddress(addressData);
      } else {
        await authService.updateAddress(widget.address!.id, addressData);
      }

      ref.invalidate(userProfileProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.address == null
                ? 'Thêm địa chỉ thành công'
                : 'Cập nhật địa chỉ thành công'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.address != null;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Sửa địa chỉ' : 'Thêm địa chỉ mới',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                label: 'Tên người nhận',
                hint: 'Nhập họ và tên',
                validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Số điện thoại',
                hint: 'Nhập số điện thoại',
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Tỉnh/Thành phố',
                hint: 'Chọn Tỉnh/Thành phố',
                value: _selectedProvince,
                items: _provinces,
                onChanged: (val) {
                  setState(() {
                    _selectedProvince = val;
                    _selectedDistrict = null;
                    _districts = [];
                  });
                  if (val != null) {
                    _fetchDistricts(val['code']);
                  }
                },
                validator: (v) => v == null ? 'Vui lòng chọn Tỉnh/Thành' : null,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Quận/Huyện',
                hint: 'Chọn Quận/Huyện',
                value: _selectedDistrict,
                items: _districts,
                onChanged: (val) {
                  setState(() {
                    _selectedDistrict = val;
                  });
                },
                validator: (v) => v == null ? 'Vui lòng chọn Quận/Huyện' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _streetController,
                label: 'Tên đường, Tòa nhà, Số nhà',
                hint: 'Nhập địa chỉ chi tiết',
                validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Đặt làm địa chỉ mặc định',
                    style: TextStyle(fontSize: 14, color: AppColors.textDark)),
                activeColor: AppColors.primary,
                value: _isDefault,
                onChanged: (val) => setState(() => _isDefault = val),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          isEditing ? 'Lưu thay đổi' : 'Hoàn thành',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required dynamic value,
    required List<dynamic> items,
    required void Function(dynamic) onChanged,
    String? Function(dynamic)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey)),
        const SizedBox(height: 4),
        DropdownButtonFormField<dynamic>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          hint: Text(hint),
          items: items.map((item) {
            return DropdownMenuItem<dynamic>(
              value: item,
              child: Text(item['name'], style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}

