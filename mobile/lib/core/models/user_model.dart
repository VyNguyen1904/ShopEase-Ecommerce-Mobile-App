class UserModel {
  final String id;
  final String username;
  final String email;
  final String role;
  final bool isEnabled;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.isEnabled,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'BUYER',
      isEnabled: json['enabled'] ?? json['isEnabled'] ?? true,
    );
  }
}
