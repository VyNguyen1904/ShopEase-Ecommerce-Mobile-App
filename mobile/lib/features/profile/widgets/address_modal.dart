import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/address_model.dart';
import 'address_map_preview.dart';

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
  double? _latitude;
  double? _longitude;

  List<dynamic> _provinces = [];
  List<dynamic> _wards = [];
  dynamic _selectedProvince;
  dynamic _selectedWard;

  @override
  void initState() {
    super.initState();
    final addr = widget.address;
    _nameController = TextEditingController(text: addr?.name ?? '');
    _phoneController = TextEditingController(text: addr?.phone ?? '');
    _streetController = TextEditingController(text: addr?.address1 ?? '');
    _isDefault = addr?.isDefault ?? false;
    _latitude = addr?.latitude;
    _longitude = addr?.longitude;

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
                _fetchWardsByProvince(_selectedProvince['code']);
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

  Future<void> _fetchWardsByProvince(int provinceCode) async {
    try {
      final response = await Dio().get(
        'https://provinces.open-api.vn/api/p/$provinceCode?depth=3',
      );
      if (mounted) {
        List<dynamic> allWards = [];
        for (var d in response.data['districts']) {
          for (var w in d['wards']) {
            w['displayName'] = '${w['name']} (${d['name']})';
            w['district_name'] = d['name'];
            allWards.add(w);
          }
        }
        setState(() {
          _wards = allWards;
          // Try to select initial ward if editing
          final addrStreet = widget.address?.address1;
          if (addrStreet != null && addrStreet.isNotEmpty) {
            try {
              _selectedWard = _wards.firstWhere(
                (w) => addrStreet.contains(w['name']),
              );
            } catch (e) {
              // Not found
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching wards: $e');
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
      address1:
          '${_streetController.text.trim()}${_selectedWard != null ? ', ${_selectedWard['name']}' : ''}',
      address2:
          '${_selectedWard != null ? _selectedWard['district_name'] : ''}, ${_selectedProvince?['name'] ?? ''}',
      isDefault: _isDefault,
      latitude: _latitude,
      longitude: _longitude,
    );

    try {
      final authService = ref.read(authServiceProvider);
      if (widget.address == null) {
        await authService.addAddress(addressData);
      } else {
        await authService.updateAddress(widget.address!.id, addressData);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.address == null
                  ? AppStrings.addAddressSuccess
                  : AppStrings.updateAddressSuccess,
            ),
          ),
        );
      }

      ref.invalidate(userProfileProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${AppStrings.errorPrefix}$e')));
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
                    isEditing
                        ? AppStrings.editAddress
                        : AppStrings.addNewAddress,
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
                label: AppStrings.receiverName,
                hint: AppStrings.fullNameHint,
                validator: (v) =>
                    v!.isEmpty ? AppStrings.notEmptyRequired : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: AppStrings.phoneLabel,
                hint: AppStrings.phoneHint,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v!.isEmpty ? AppStrings.notEmptyRequired : null,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: AppStrings.province,
                hint: AppStrings.provinceHint,
                value: _selectedProvince,
                items: _provinces,
                onChanged: (val) {
                  setState(() {
                    _selectedProvince = val;
                    _selectedWard = null;
                    _wards = [];
                  });
                  if (val != null) {
                    _fetchWardsByProvince(val['code']);
                  }
                },
                validator: (v) =>
                    v == null ? AppStrings.pleaseSelectProvince : null,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: AppStrings.ward,
                hint: AppStrings.wardHint,
                value: _selectedWard,
                items: _wards,
                onChanged: (val) {
                  setState(() {
                    _selectedWard = val;
                  });
                },
                validator: (v) =>
                    v == null ? AppStrings.pleaseSelectWard : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _streetController,
                label: AppStrings.streetAddress,
                hint: AppStrings.streetAddressHint,
                validator: (v) =>
                    v!.isEmpty ? AppStrings.notEmptyRequired : null,
              ),
              const SizedBox(height: 16),
              // Embedded Map Thumbnail
              AddressMapPreview(
                latitude: _latitude,
                longitude: _longitude,
                selectedProvince: _selectedProvince,
                selectedWard: _selectedWard,
                streetAddress: _streetController.text,
                provinces: _provinces,
                wards: _wards,
                onLocationUpdated:
                    (
                      lat,
                      lng,
                      matchedProvince,
                      matchedWard,
                      updatedWards,
                      street,
                    ) {
                      setState(() {
                        _latitude = lat;
                        _longitude = lng;
                        _streetController.text = street;

                        if (matchedProvince != null &&
                            _selectedProvince != matchedProvince) {
                          _selectedProvince = matchedProvince;
                          _selectedWard = null;
                          _wards = [];
                          _fetchWardsByProvince(matchedProvince['code']);
                        } else {
                          _selectedWard = matchedWard;
                          _wards = updatedWards;
                        }
                      });
                    },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  AppStrings.setAsDefault,
                  style: TextStyle(fontSize: 14, color: AppColors.textDark),
                ),
                activeThumbColor: AppColors.primary,
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
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isEditing ? AppStrings.saveChanges : AppStrings.done,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textGrey,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Future<void> _showSearchablePicker({
    required String title,
    required List<dynamic> items,
    required void Function(dynamic) onSelected,
  }) async {
    showDialog(
      context: context,
      builder: (context) {
        String query = "";
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredItems = items.where((element) {
              final name = (element['name'] as String).toLowerCase();
              return name.contains(query.toLowerCase());
            }).toList();

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: AppStrings.searchHint,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (val) {
                        setDialogState(() {
                          query = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filteredItems.isEmpty
                          ? const Center(child: Text(AppStrings.noResultFound))
                          : ListView.builder(
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                return ListTile(
                                  title: Text(
                                    item['displayName'] ?? item['name'],
                                  ),
                                  onTap: () {
                                    onSelected(item);
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textGrey,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          readOnly: true,
          controller: TextEditingController(
            text: value != null ? (value['displayName'] ?? value['name']) : '',
          ),
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          onTap: () {
            if (items.isEmpty) return;
            _showSearchablePicker(
              title: label,
              items: items,
              onSelected: onChanged,
            );
          },
          validator: (val) => validator?.call(value),
        ),
      ],
    );
  }
}
