import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/admin_stats_model.dart';

class AdminUserService {
  final Dio _dio;

  String get _host {
    if (kIsWeb) {
      final host = Uri.base.host;
      return "http://${host.isNotEmpty ? host : '127.0.0.1'}:8000";
    }
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    } catch (_) {}
    return 'http://127.0.0.1:8000';
  }

  String get _baseUrl => '$_host/api/admin/users';

  AdminUserService({Dio? dio}) : _dio = dio ?? Dio();

  Future<Options> _getAuthOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return Options(
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
  }

  Future<List<UserModel>> getUsers({int page = 0, int size = 100}) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '$_baseUrl?page=$page&size=$size',
        options: options,
      );

      final dynamic data = response.data['data'];
      if (data == null) return [];

      final List<dynamic> content = data['content'] ?? [];
      return content.map((json) => UserModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load users');
    }
  }

  Future<UserModel> createUser(String username, String email, String password, String role) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        _baseUrl,
        options: options,
        data: {
          'username': username,
          'email': email,
          'password': password,
          'role': role,
        },
      );

      final data = response.data['data'];
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create user');
    }
  }

  Future<UserModel> updateUserRole(String id, String role) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.put(
        '$_baseUrl/$id/role',
        options: options,
        data: {'role': role},
      );

      final data = response.data['data'];
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update role');
    }
  }

  Future<UserModel> updateUserStatus(String id, bool enabled) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.put(
        '$_baseUrl/$id/status?enabled=$enabled',
        options: options,
      );

      final data = response.data['data'];
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update status');
    }
  }

  Future<UserModel> updateUser(String id, String username, String email, String role) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.put(
        '$_baseUrl/$id',
        options: options,
        data: {
          'username': username,
          'email': email,
          'role': role,
        },
      );

      final data = response.data['data'];
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update user');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      final options = await _getAuthOptions();
      await _dio.delete(
        '$_baseUrl/$id',
        options: options,
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to delete user');
    }
  }

  Future<AdminUserStats> getUserStats() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '$_host/api/admin/users/stats',
        options: options,
      );
      final data = response.data['data'];
      return AdminUserStats.fromJson(data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load user stats');
    }
  }

  Future<AdminOrderStats> getOrderStats() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '$_host/api/admin/orders/stats',
        options: options,
      );
      final data = response.data['data'];
      return AdminOrderStats.fromJson(data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load order stats');
    }
  }

  Future<CombinedAdminStats> getCombinedStats() async {
    try {
      final results = await Future.wait([
        getUserStats(),
        getOrderStats(),
      ]);
      return CombinedAdminStats(
        userStats: results[0] as AdminUserStats,
        orderStats: results[1] as AdminOrderStats,
      );
    } catch (e) {
      throw Exception('Failed to load system statistics: $e');
    }
  }
}
