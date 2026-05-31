import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import '../models/auth_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio;

  String get _host {
    if (kIsWeb) return 'http://localhost:8080';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    } catch (_) {}
    return 'http://localhost:8080';
  }

  String get _authUrl => '$_host/api/auth';
  String get _userUrl => '$_host/api/users';

  AuthService({Dio? dio}) : _dio = dio ?? Dio();

  Future<TokenResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '$_authUrl/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data['data'];
      final tokenResponse = TokenResponse.fromJson(data);
      await _saveTokens(tokenResponse);

      return tokenResponse;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Login failed');
    }
  }

  Future<TokenResponse> register(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      final response = await _dio.post(
        '$_authUrl/register',
        data: {
          'email': email,
          'password': password,
          'fullName': fullName,
          'role': 'BUYER',
        },
      );

      final data = response.data['data'];
      final tokenResponse = TokenResponse.fromJson(data);
      await _saveTokens(tokenResponse);
      return tokenResponse;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Registration failed');
    }
  }

  Future<UserResponse> getProfile() async {
    try {
      final token = await getAccessToken();
      if (token == null) throw Exception('No token found');

      final response = await _dio.get(
        '$_userUrl/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return UserResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get profile');
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      final accessToken = prefs.getString('access_token');

      if (refreshToken != null && accessToken != null) {
        await _dio.post(
          '$_authUrl/logout',
          data: {'refreshToken': refreshToken},
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
        );
      }
    } catch (e) {
      // Ignore errors during logout
    } finally {
      await _clearTokens();
    }
  }

  // --- Token Management Helpers ---

  Future<void> _saveTokens(TokenResponse tokens) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', tokens.accessToken);
    await prefs.setString('refresh_token', tokens.refreshToken);
  }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }
}
