import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/admin_stats_model.dart';
import '../services/admin_user_service.dart';

import 'auth_provider.dart';

final adminUserServiceProvider = Provider<AdminUserService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AdminUserService(dio: authService.dio);
});

final adminUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final adminService = ref.watch(adminUserServiceProvider);
  return adminService.getUsers();
});

final adminStatsProvider = FutureProvider<CombinedAdminStats>((ref) async {
  final adminService = ref.watch(adminUserServiceProvider);
  return adminService.getCombinedStats();
});
