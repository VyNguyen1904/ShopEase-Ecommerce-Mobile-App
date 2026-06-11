class AddressModel {
  final String? id;
  final String name;
  final String phone;
  final String address1;
  final String address2;
  final String label;
  final bool isDefault;

  AddressModel({
    this.id,
    required this.name,
    required this.phone,
    required this.address1,
    this.address2 = '',
    this.label = '',
    this.isDefault = false,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'recipientName': name,
      'phone': phone,
      'address1': address1,
      'street': address1,
      'address2': address2,
      'city': address2,
      'district': '',
      'label': label,
      'isDefault': isDefault,
      'defaultAddress': isDefault,
    };
  }
}
