import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/auth_model.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final userProfileProvider = FutureProvider<UserResponse>((ref) async {
  final authService = ref.read(authServiceProvider);
  return await authService.getProfile();
});
