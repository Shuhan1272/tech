import 'package:dio/dio.dart';
import '../core/api_client.dart'; // Make sure this path is correct in your project

class AuthService {
  // Use the ApiClient instance so the JWT token is automatically attached!
  static final Dio _dio = ApiClient.instance.dio;

  // =========================================================
  // REGISTER
  // =========================================================
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
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // =========================================================
  // VERIFY EMAIL OTP
  // =========================================================
  static Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _dio.post('/accounts/verify-email/', data: {
        'email': email,
        'otp': otp,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // =========================================================
  // LOGIN
  // =========================================================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/accounts/token/', data: {
        'email': email,
        'password': password,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // =========================================================
  // FORGOT PASSWORD
  // =========================================================
  static Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    try {
      final response = await _dio.post('/accounts/forgot-password/', data: {'email': email});
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // =========================================================
  // VERIFY PASSWORD OTP
  // =========================================================
  static Future<Map<String, dynamic>> verifyPasswordOTP({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _dio.post('/accounts/verify-password-otp/', data: {
        'email': email,
        'otp': otp,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // =========================================================
  // RESET PASSWORD
  // =========================================================
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
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // =========================================================
  // GET PROFILE (No token parameter needed anymore!)
  // =========================================================
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/accounts/me/');
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // =========================================================
  // UPDATE PROFILE (No token parameter needed anymore!)
  // =========================================================
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
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // =========================================================
  // GET ADDRESS (No token parameter needed anymore!)
  // =========================================================
  static Future<Map<String, dynamic>> getAddress() async {
    try {
      final response = await _dio.get('/accounts/address/');
      final data = response.data;
      if (data is List && data.isNotEmpty) {
        return data[0];
      } else {
        return {};
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // =========================================================
  // CREATE ADDRESS (New method for AddressProvider)
  // =========================================================
  static Future<Map<String, dynamic>> createAddress(Map<String, dynamic> input) async {
    try {
      final response = await _dio.post('/accounts/address/', data: input);
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // =========================================================
  // UPDATE ADDRESS (New method for AddressProvider)
  // =========================================================
  static Future<Map<String, dynamic>> updateAddress(int id, Map<String, dynamic> input) async {
    try {
      final response = await _dio.put('/accounts/address/$id/', data: input);
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // =========================================================
  // DELETE ADDRESS (New method for AddressProvider)
  // =========================================================
  static Future<void> deleteAddress(int id) async {
    try {
      await _dio.delete('/accounts/address/$id/');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // =========================================================
  // CHANGE PASSWORD (No token parameter needed anymore!)
  // =========================================================
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
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // =========================================================
  // HELPER: Extract error message from DioException
  // =========================================================
  static String _handleDioError(DioException e) {
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map) {
        if (data.containsKey('detail')) return data['detail'].toString();
        if (data.containsKey('non_field_errors')) return data['non_field_errors'].toString();
        final firstError = data.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError[0].toString();
        }
        return firstError.toString();
      }
      return data.toString();
    }
    return e.message ?? 'An unexpected network error occurred';
  }
}