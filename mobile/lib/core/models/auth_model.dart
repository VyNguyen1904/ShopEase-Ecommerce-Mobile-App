class TokenResponse {
  final String accessToken;
  final String refreshToken;

  TokenResponse({required this.accessToken, required this.refreshToken});

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
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

  UserResponse({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.avatar,
    required this.role,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
      role: json['role'] ?? 'CUSTOMER',
    );
  }
}
