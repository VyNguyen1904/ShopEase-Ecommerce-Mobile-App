import 'dart:io' show Platform;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import '../models/auth_model.dart';
import '../models/address_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_strings.dart';

class AuthService {
  final Dio _dio;
  Future<TokenResponse>? _refreshTokenFuture;
  
  Dio get dio => _dio;

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

  String get _authUrl => '$_host/api/auth';
  String get _userUrl => '$_host/api/users';

  AuthService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final isAuthRoute = options.path.contains('/api/auth/login') || 
                              options.path.contains('/api/auth/register') ||
                              options.path.contains('/api/auth/verify-email') ||
                              options.path.contains('/api/auth/resend-otp') ||
                              options.path.contains('/api/auth/refresh') ||
                              options.path.endsWith('/api/auth/logout');
          
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
        onError: (DioException e, handler) async {
          final path = e.requestOptions.path;
          // Auth endpoints must NEVER trigger a refresh attempt
          final isAuthEndpoint = path.contains('/api/auth/login') ||
              path.contains('/api/auth/register') ||
              path.contains('/api/auth/refresh') ||
              path.contains('/api/auth/verify-email') ||
              path.contains('/api/auth/resend-otp');

          if (e.response?.statusCode == 401 && !isAuthEndpoint) {
            try {
              // Deduplicate refresh token requests
              _refreshTokenFuture ??= refreshToken().whenComplete(() {
                _refreshTokenFuture = null;
              });
              
              final tokenResponse = await _refreshTokenFuture!;
              
              // Update the original request with the new token
              e.requestOptions.headers['Authorization'] = 'Bearer ${tokenResponse.accessToken}';
              
              // Create a new Dio instance to retry the request without triggering interceptor loops
              final retryDio = Dio();
              final retryResponse = await retryDio.fetch(e.requestOptions);
              return handler.resolve(retryResponse);
            } catch (refreshError) {
              await _clearTokens();
              // Force redirect to login by throwing a specific error
              return handler.next(DioException(
                requestOptions: e.requestOptions,
                error: 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.',
                type: DioExceptionType.unknown,
              ));
            }
          }
          if (e.response?.statusCode == 401 && !isAuthEndpoint) {
            await _clearTokens();
          }
          return handler.next(e);
        },
      ),
    );
  }

  String _handleDioError(DioException e) {
    if (e.error == 'Vui lòng đăng nhập lại') return e.error.toString();

    // Fast-path: sai mật khẩu khi đăng nhập
    if (e.response?.statusCode == 401 && e.requestOptions.path.contains('/login')) {
      return AppStrings.errBadCredentials;
    }

    String translateError(String message) {
      final lowerMsg = message.toLowerCase();
      const errorMappings = {
        'bad credentials': AppStrings.errBadCredentials,
        'invalid credentials': AppStrings.errBadCredentials,
        'password': AppStrings.errBadCredentials,
        'user not found': AppStrings.errUserNotFound,
        'already exists': AppStrings.errEmailTaken,
        'already taken': AppStrings.errEmailTaken,
        'unauthorized': AppStrings.errUnauthorized,
        'forbidden': AppStrings.errForbidden,
        'internal server error': AppStrings.errInternalServer,
      };

      final match = errorMappings.entries.where((entry) => lowerMsg.contains(entry.key)).firstOrNull;
      return match?.value ?? message;
    }

    final data = e.response?.data;
    final serverMessage = switch (data) {
      Map() when data['message'] != null => data['message'].toString(),
      Map() when data['error'] != null   => data['error'].toString(),
      Map() when data['errors'] is List && (data['errors'] as List).isNotEmpty
          => (data['errors'] as List).first.toString(),
      _ => null,
    };

    return serverMessage != null
        ? translateError(serverMessage)
        : e.response != null
            ? (e.response!.statusMessage?.isNotEmpty == true
                ? e.response!.statusMessage!
                : '${AppStrings.errServerStatus} (${e.response!.statusCode})')
            : switch (e.type) {
                DioExceptionType.connectionTimeout ||
                DioExceptionType.receiveTimeout => AppStrings.errConnectionTimeout,
                DioExceptionType.connectionError => AppStrings.errConnectionError,
                _ => e.message?.isNotEmpty == true
                    ? '${AppStrings.errOccurred}${e.message}'
                    : AppStrings.unknownError,
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

  Future<void> register(String email, String password, String fullName) async {
    try {
      await _dio.post(
        '$_authUrl/register',
        data: {'email': email, 'password': password, 'fullName': fullName, 'role': 'BUYER'},
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<TokenResponse> verifyEmail(String email, String otp) async {
    try {
      final response = await _dio.post(
        '$_authUrl/verify-email',
        data: {'email': email, 'otp': otp},
      );
      final tokenResponse = TokenResponse.fromJson(response.data['data']);
      await _saveTokens(tokenResponse);
      return tokenResponse;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<void> resendOtp(String email) async {
    try {
      await _dio.post(
        '$_authUrl/resend-otp',
        data: {'email': email},
      );
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

  Future<UserResponse> getUserById(String id) async {
    try {
      final response = await _dio.get('$_userUrl/$id');
      return UserResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<UserResponse> updateProfile(String fullName, String? phone, String? avatarUrl) async {
    try {
      final data = {
        'fullName': fullName,
        'phone': phone,
        'avatarUrl': avatarUrl,
      };

      final response = await _dio.put('$_userUrl/me', data: data);
      return UserResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }


  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final token = await getAccessToken();
      await _dio.post(
        '$_authUrl/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<void> addAddress(AddressModel address) async {
    try {
      final token = await getAccessToken();
      await _dio.post(
        '$_userUrl/me/addresses',
        data: address.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to add address');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> updateAddress(String id, AddressModel address) async {
    try {
      final token = await getAccessToken();
      await _dio.put(
        '$_userUrl/me/addresses/$id',
        data: address.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update address');
    } catch (e) {
      throw Exception('Unexpected error: $e');
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

  Future<String?> getUserId() async {
    try {
      final token = await getAccessToken();
      if (token == null) return null;
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final Map<String, dynamic> data = jsonDecode(payload);
      return data['userId']?.toString() ?? data['sub']?.toString();
    } catch (_) {
      return null;
    }
  }
}
