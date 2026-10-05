import 'package:dio/dio.dart';
import '../core/api_client.dart';

/// Rewritten to go through the shared ApiClient instead of building raw
/// http requests by hand. Two concrete fixes:
///
///  1. Every method used to require a `token` parameter the caller had to
///     fetch from storage and pass in. ApiClient's interceptor attaches
///     the Authorization header automatically now, so none of these need
///     a token argument — and a call made with an expired access token
///     gets silently refreshed and retried instead of just failing.
///  2. This used a different base URL/host than product_service.dart.
///     Both now share ApiConstants.baseUrl.
///
/// Added: updateAddress/deleteAddress, which didn't exist. The old
/// saveAddress() only ever POSTed, which fails once an address already
/// exists (Address is one-to-one with the user on the backend), so
/// editing a saved address was impossible.
class AuthService {
  static final Dio _dio = ApiClient.instance.dio;

  static Future<Map<String, dynamic>> register({
    required String email,
    required String phone,
    required String firstName,
    required String lastName,
    required String password,
    required String password2,
  }) async {
    try {
      final response = await _dio.post('/accounts/register/', data: {
        'email': email,
        'phone': phone,
        'first_name': firstName,
        'last_name': lastName,
        'password': password,
        'password2': password2,
      });
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e));
    }
  }

  static Future<Map<String, dynamic>> verifyEmail({required String email, required String otp}) async {
    try {
      final response = await _dio.post('/accounts/verify-email/', data: {'email': email, 'otp': otp});
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e));
    }
  }

  static Future<Map<String, dynamic>> login({required String email, required String password}) async {
    try {
      final response = await _dio.post('/accounts/token/', data: {'email': email, 'password': password});
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e));
    }
  }

  static Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    try {
      final response = await _dio.post('/accounts/forgot-password/', data: {'email': email});
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e));
    }
  }

  static Future<Map<String, dynamic>> verifyPasswordOTP({required String email, required String otp}) async {
    try {
      final response = await _dio.post('/accounts/verify-password-otp/', data: {'email': email, 'otp': otp});
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e));
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String resetToken,
    required String password,
    required String password2,
  }) async {
    try {
      final response = await _dio.post('/accounts/reset-password/', data: {
        'reset_token': resetToken,
        'password': password,
        'password2': password2,
      });
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e));
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/accounts/me/');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e));
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    try {
      final response = await _dio.patch('/accounts/me/', data: {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
      });
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e));
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPassword2,
  }) async {
    try {
      final response = await _dio.post('/accounts/change-password/', data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password2': newPassword2,
      });
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e));
    }
  }

  // =========================================================
  // ADDRESS — one per user (one-to-one on the backend)
  // =========================================================

  /// Returns null when the user has no address saved yet, instead of the
  /// old empty {} that every caller had to remember to check for.
  static Future<Map<String, dynamic>?> getAddress() async {
    try {
      final response = await _dio.get('/accounts/address/');
      final data = response.data;
      final List results = data is List ? data : (data['results'] as List? ?? []);
      if (results.isEmpty) return null;
      return Map<String, dynamic>.from(results.first);
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e));
    }
  }

  static Future<Map<String, dynamic>> createAddress(Map<String, dynamic> address) async {
    try {
      final response = await _dio.post('/accounts/address/', data: address);
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e));
    }
  }

  static Future<Map<String, dynamic>> updateAddress(int id, Map<String, dynamic> address) async {
    try {
      final response = await _dio.put('/accounts/address/$id/', data: address);
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e));
    }
  }

  static Future<void> deleteAddress(int id) async {
    try {
      await _dio.delete('/accounts/address/$id/');
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e));
    }
  }
}
