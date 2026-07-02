class AddressModel {
  final String? id;
  final String name;
  final String phone;
  final String address1;
  final String address2;
  final String label;
  final bool isDefault;
  final double? latitude;
  final double? longitude;

  AddressModel({
    this.id,
    required this.name,
    required this.phone,
    required this.address1,
    this.address2 = '',
    this.label = '',
    this.isDefault = false,
    this.latitude,
    this.longitude,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      name: json['name'] ?? json['recipientName'] ?? '',
      phone: json['phone'] ?? '',
      address1: json['address1'] ?? json['street'] ?? '',
      address2: json['address2'] ?? 
          ((json['district'] != null && json['city'] != null) 
              ? '${json['district']}, ${json['city']}' 
              : (json['city'] ?? json['district'] ?? '')),
      label: json['label'] ?? '',
      isDefault: json['isDefault'] ?? json['defaultAddress'] ?? json['default'] ?? false,
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    String cityStr = address2;
    String districtStr = '';
    
    if (address2.contains(', ')) {
      final parts = address2.split(', ');
      districtStr = parts[0];
      cityStr = parts.length > 1 ? parts.sublist(1).join(', ') : parts[0];
    }

    return {
      if (id != null) 'id': id,
      'name': name,
      'recipientName': name,
      'phone': phone,
      'address1': address1,
      'street': address1,
      'address2': address2,
      'city': cityStr,
      'district': districtStr,
      'label': label,
      'isDefault': isDefault,
      'defaultAddress': isDefault,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }
}
