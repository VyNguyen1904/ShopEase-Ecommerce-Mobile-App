import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/address_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../screens/map_picker_screen.dart';

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
      final response = await Dio().get('https://provinces.open-api.vn/api/p/$provinceCode?depth=3');
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
      address1: '${_streetController.text.trim()}${_selectedWard != null ? ', ${_selectedWard['name']}' : ''}',
      address2: '${_selectedWard != null ? _selectedWard['district_name'] : ''}, ${_selectedProvince?['name'] ?? ''}',
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
            content: Text(widget.address == null
                ? AppStrings.addAddressSuccess
                : AppStrings.updateAddressSuccess),
          ),
        );
      }

      ref.invalidate(userProfileProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.errorPrefix}$e')),
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
                    isEditing ? AppStrings.editAddress : AppStrings.addNewAddress,
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
                validator: (v) => v!.isEmpty ? AppStrings.notEmptyRequired : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: AppStrings.phoneLabel,
                hint: AppStrings.phoneHint,
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? AppStrings.notEmptyRequired : null,
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
                validator: (v) => v == null ? 'Vui lòng chọn Tỉnh/Thành' : null,
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
                validator: (v) => v == null ? 'Vui lòng chọn Phường/Xã' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _streetController,
                label: AppStrings.streetAddress,
                hint: AppStrings.streetAddressHint,
                validator: (v) => v!.isEmpty ? AppStrings.notEmptyRequired : null,
              ),
              const SizedBox(height: 16),
              // Embedded Map Thumbnail
              GestureDetector(
                onTap: () async {
                  // Navigate to Map Picker
                  String? query;
                  if (_selectedProvince != null && _streetController.text.isNotEmpty) {
                    final districtPart = _selectedWard != null ? '${_selectedWard['district_name']}, ' : '';
                    final wardPart = _selectedWard != null ? '${_selectedWard['name']}, ' : '';
                    query = '${_streetController.text}, $wardPart$districtPart${_selectedProvince['name']}';
                  }
                  
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MapPickerScreen(
                        initialLocation: _latitude != null && _longitude != null 
                          ? LatLng(_latitude!, _longitude!) 
                          : null,
                        searchQuery: query,
                      ),
                    )
                  );
                  if (result != null) {
                    setState(() {
                      _latitude = result['latitude'];
                      _longitude = result['longitude'];
                      if (result['raw'] != null && result['raw']['address'] != null) {
                         final addr = result['raw']['address'] ?? {};
                         final displayName = (result['raw']['display_name']?.toString() ?? '').toLowerCase();
                         
                         // Fix Province Mapping (Robust display_name scanner)
                         dynamic matchedProvince;
                         final displayNameParts = displayName.split(',').map((e) => e.trim()).toList();
                         
                         // First try exact match on parts
                         for (var p in _provinces) {
                            final pName = p['name'].toString().toLowerCase();
                            final pShort = pName.replaceFirst(RegExp(r'^(thành phố|tỉnh)\s+'), '').trim();
                            if (displayNameParts.contains(pName) || displayNameParts.contains(pShort)) {
                               matchedProvince = p;
                               break;
                            }
                         }
                         
                         // Fallback to contains on the tail of display_name
                         if (matchedProvince == null) {
                             final tail = displayNameParts.reversed.take(4).join(', ');
                             for (var p in _provinces) {
                                final pName = p['name'].toString().toLowerCase();
                                final pShort = pName.replaceFirst(RegExp(r'^(thành phố|tỉnh)\s+'), '').trim();
                                if (tail.contains(pName) || tail.contains(pShort)) {
                                   matchedProvince = p;
                                   break;
                                }
                             }
                         }

                         if (matchedProvince != null) {
                            if (_selectedProvince != matchedProvince) {
                                _selectedWard = null;
                                _wards = [];
                            }
                            _selectedProvince = matchedProvince;
                            
                            _fetchWardsByProvince(_selectedProvince['code']).then((_) {
                                if (mounted) {
                                    dynamic matchedWard;
                                    String districtRaw = (addr['city_district'] ?? addr['county'] ?? addr['town'] ?? '').toString().toLowerCase();
                                    
                                    for (var w in _wards) {
                                        final wName = w['name'].toString().toLowerCase();
                                        final wDistrict = w['district_name'].toString().toLowerCase();
                                        
                                        if (displayName.contains(wName)) {
                                            if (districtRaw.isNotEmpty && (districtRaw.contains(wDistrict) || wDistrict.contains(districtRaw))) {
                                                matchedWard = w;
                                                break;
                                            } else if (displayName.contains(wDistrict)) {
                                                matchedWard = w;
                                                break;
                                            } else if (matchedWard == null) {
                                                matchedWard = w; // Store first match as fallback
                                            }
                                        }
                                    }
                                    // Fallback to addr fields
                                    if (matchedWard == null) {
                                        final fallbackW = (addr['suburb'] ?? addr['village'] ?? addr['quarter'] ?? '').toString().toLowerCase();
                                        if (fallbackW.isNotEmpty) {
                                            try {
                                                matchedWard = _wards.firstWhere((w) => fallbackW.contains(w['name'].toString().toLowerCase()) || w['name'].toString().toLowerCase().contains(fallbackW));
                                            } catch (e) {}
                                        }
                                    }
                                    // If STILL not found, use Map's ward name directly (Create custom Ward)
                                    if (matchedWard == null) {
                                        String customWard = (addr['suburb'] ?? addr['village'] ?? addr['quarter'] ?? '').toString();
                                        if (customWard.isEmpty) {
                                            final RegExp wardRegExp = RegExp(r'(Phường|Xã|Thị trấn)\s+[^,]+', caseSensitive: false);
                                            final match = wardRegExp.firstMatch(result['raw']['display_name'] ?? '');
                                            if (match != null) { customWard = match.group(0)!; }
                                        }
                                        if (customWard.isNotEmpty) {
                                            customWard = customWard.split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}' : '').join(' ');
                                            matchedWard = {
                                                'name': customWard,
                                                'displayName': customWard,
                                                'district_name': '',
                                                'code': -1
                                            };
                                            _wards.insert(0, matchedWard); // Add to top of list
                                        }
                                    }

                                    setState(() {
                                        _selectedWard = matchedWard;
                                    });
                                }
                            });
                         }
                         
                         String street = addr['road'] ?? '';
                         if (addr['house_number'] != null) street = '${addr['house_number']} $street';
                         _streetController.text = street;
                      } else if (result['address'] != null) {
                         _streetController.text = result['address'];
                      }
                    });
                  }
                },
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    children: [
                      AbsorbPointer( // Prevent scrolling map inside scrollview
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: _latitude != null && _longitude != null 
                              ? LatLng(_latitude!, _longitude!) 
                              : const LatLng(10.762622, 106.660172), // Default HCM
                            initialZoom: 15.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.shopease.app',
                            ),
                            if (_latitude != null && _longitude != null)
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(_latitude!, _longitude!),
                                    width: 40,
                                    height: 40,
                                    child: const Icon(Icons.location_on, color: AppColors.primary, size: 40),
                                  )
                                ],
                              )
                          ],
                        ),
                      ),
                      // Overlay hint
                      Positioned(
                        bottom: 8,
                        left: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.touch_app, size: 16, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                _latitude != null ? 'Chạm để sửa vị trí' : 'Chạm để ghim vị trí',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(AppStrings.setAsDefault,
                    style: TextStyle(fontSize: 14, color: AppColors.textDark)),
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
                          isEditing ? AppStrings.saveChanges : AppStrings.done,
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: "Tìm kiếm...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                          ? const Center(child: Text("Không tìm thấy kết quả"))
                          : ListView.builder(
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                return ListTile(
                                  title: Text(item['displayName'] ?? item['name']),
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
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey)),
        const SizedBox(height: 4),
        TextFormField(
          readOnly: true,
          controller: TextEditingController(text: value != null ? (value['displayName'] ?? value['name']) : ''),
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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

