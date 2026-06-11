import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import '../models/auth_model.dart';
import '../models/address_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio;

  String get _host {
    if (kIsWeb) return 'http://localhost:8000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    } catch (_) {}
    return 'http://localhost:8000';
  }

  String get _authUrl => '$_host/api/auth';
  String get _userUrl => '$_host/api/users';

  AuthService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final isAuthRoute = options.path.contains('/api/auth/login') || 
                              options.path.contains('/api/auth/register');
          
          if (!isAuthRoute) {
            final token = await getAccessToken();
            if (token == null) {
              return handler.reject(
                DioException(
                  requestOptions: options,
                  error: 'Vui lòng đăng nhập lại',
                  type: DioExceptionType.unknown,
                ),
              );
            }
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  String _handleDioError(DioException e) {
    if (e.error == 'Vui lòng đăng nhập lại') return e.error.toString();

    String translateError(String message) {
      final lowerMsg = message.toLowerCase();
      const errorMappings = {
        'bad credentials': 'Sai email hoặc mật khẩu.',
        'invalid credentials': 'Sai email hoặc mật khẩu.',
        'password': 'Sai email hoặc mật khẩu.',
        'user not found': 'Không tìm thấy tài khoản với email này.',
        'already exists': 'Email này đã được sử dụng. Vui lòng chọn email khác.',
        'already taken': 'Email này đã được sử dụng. Vui lòng chọn email khác.',
        'unauthorized': 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
        'forbidden': 'Bạn không có quyền thực hiện thao tác này.',
        'internal server error': 'Lỗi máy chủ. Vui lòng thử lại sau.',
      };

      final match = errorMappings.entries.where((entry) => lowerMsg.contains(entry.key)).firstOrNull;
      return match?.value ?? message;
    }

    final data = e.response?.data;
    final serverMessage = switch (data) {
      Map() when data['message'] != null => data['message'].toString(),
      Map() when data['error'] != null => data['error'].toString(),
      Map() when data['errors'] is List && (data['errors'] as List).isNotEmpty => (data['errors'] as List).first.toString(),
      _ => null,
    };

    return serverMessage != null 
        ? translateError(serverMessage) 
        : e.response != null 
            ? (e.response!.statusMessage ?? 'Lỗi máy chủ (${e.response!.statusCode})')
            : switch (e.type) {
                DioExceptionType.connectionTimeout || DioExceptionType.receiveTimeout => 'Hết thời gian kết nối. Vui lòng kiểm tra mạng.',
                DioExceptionType.connectionError => 'Không thể kết nối đến máy chủ. Vui lòng thử lại.',
                _ => 'Đã có lỗi xảy ra: ${e.message}',
              };
  }

  Future<TokenResponse> login(String email, String password) async {
    try {
      final response = await _dio.post('$_authUrl/login', data: {'email': email, 'password': password});
      final tokenResponse = TokenResponse.fromJson(response.data['data']);
      await _saveTokens(tokenResponse);
      return tokenResponse;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<TokenResponse> register(String email, String password, String fullName) async {
    try {
      final response = await _dio.post(
        '$_authUrl/register',
        data: {'email': email, 'password': password, 'fullName': fullName, 'role': 'BUYER'},
      );
      final tokenResponse = TokenResponse.fromJson(response.data['data']);
      await _saveTokens(tokenResponse);
      return tokenResponse;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<UserResponse> getProfile() async {
    try {
      final response = await _dio.get('$_userUrl/me');
      return UserResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<UserResponse> updateProfile(String fullName, String? phone, String? avatarUrl) async {
    try {
      final data = {
        'fullName': fullName,
        ?'phone': phone,
        ?'avatarUrl': avatarUrl,
      };

      final response = await _dio.put('$_userUrl/me', data: data);
      return UserResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }


  Future<AddressModel> addAddress(AddressModel address) async {
    try {
      final token = await getAccessToken();
      final response = await _dio.post(
        '$_userUrl/me/addresses',
        data: address.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return AddressModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to add address');
    }
  }

  Future<AddressModel> updateAddress(String id, AddressModel address) async {
    try {
      final token = await getAccessToken();
      final response = await _dio.put(
        '$_userUrl/me/addresses/$id',
        data: address.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return AddressModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update address');
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      final token = await getAccessToken();
      await _dio.delete(
        '$_userUrl/me/addresses/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to delete address');
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      if (refreshToken != null) {
        await _dio.post('$_authUrl/logout', data: {'refreshToken': refreshToken});
      }
    } catch (e) {
      // Ignore errors during logout
    } finally {
      await _clearTokens();
    }
  }

  Future<TokenResponse> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshTokenStr = prefs.getString('refresh_token');
      if (refreshTokenStr == null) throw Exception('No refresh token found');

      final response = await _dio.post(
        '$_authUrl/refresh',
        data: {'refreshToken': refreshTokenStr},
      );

      final data = response.data['data'];
      final tokenResponse = TokenResponse.fromJson(data);
      await _saveTokens(tokenResponse);
      return tokenResponse;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to refresh token');
    }
  }

  Future<void> logoutAll() async {
    try {
      final token = await getAccessToken();
      if (token != null) {
        await _dio.post(
          '$_authUrl/logout-all',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
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
