import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/chat_service.dart';
import 'auth_provider.dart';

final chatServiceProvider = Provider<ApiChatService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return ApiChatService(dio: authService.dio);
});
