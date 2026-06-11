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
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address1: json['address1'] ?? '',
      address2: json['address2'] ?? '',
      label: json['label'] ?? '',
      isDefault: json['isDefault'] ?? json['default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      'address1': address1,
      'address2': address2,
      'label': label,
      'isDefault': isDefault,
    };
  }
}
