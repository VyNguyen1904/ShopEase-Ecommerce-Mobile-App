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

  try {
    return await authService.getProfile();
  } catch (e) {
    // If 401/Unauthorized, clear tokens silently and return null (show login UI)
    final msg = e.toString().toLowerCase();
    if (msg.contains('unauthorized') ||
        msg.contains('401') ||
        msg.contains('đăng nhập')) {
      await authService.logout();
      return null;
    }
    rethrow;
  }
});
