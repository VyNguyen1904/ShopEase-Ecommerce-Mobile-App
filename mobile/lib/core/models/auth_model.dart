import 'address_model.dart';

class TokenResponse {
  final String accessToken;
  final String refreshToken;

  TokenResponse({required this.accessToken, required this.refreshToken});

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken:
          json['accessToken'] ?? json['access_token'] ?? json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? json['refresh_token'] ?? '',
    );
  }
}

class UserResponse {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? avatar;
  final String role;
  final List<AddressModel> addresses;

  UserResponse({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.avatar,
    required this.role,
    this.addresses = const [],
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
      role: json['role'] ?? 'CUSTOMER',
      addresses:
          (json['addresses'] as List?)
              ?.map((e) => AddressModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
