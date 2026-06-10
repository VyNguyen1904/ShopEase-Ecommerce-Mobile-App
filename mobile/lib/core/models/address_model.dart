class AddressModel {
  final String id;
  final String recipientName;
  final String phone;
  final String street;
  final String district;
  final String city;
  final bool defaultAddress;

  AddressModel({
    required this.id,
    required this.recipientName,
    required this.phone,
    required this.street,
    required this.district,
    required this.city,
    required this.defaultAddress,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? '',
      recipientName: json['recipientName'] ?? '',
      phone: json['phone'] ?? '',
      street: json['street'] ?? '',
      district: json['district'] ?? '',
      city: json['city'] ?? '',
      defaultAddress: json['defaultAddress'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipientName': recipientName,
      'phone': phone,
      'street': street,
      'district': district,
      'city': city,
      'defaultAddress': defaultAddress,
    };
  }
}
