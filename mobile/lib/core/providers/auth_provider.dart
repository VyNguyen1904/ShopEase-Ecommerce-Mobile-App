import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_model.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final userProfileProvider = FutureProvider<UserResponse?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final token = await authService.getAccessToken();
  if (token == null || token.isEmpty) return null;
  
  return authService.getProfile();
});
