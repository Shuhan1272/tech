import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // ⚠️ CHANGE THIS TO YOUR BACKEND URL
  // If using Android Emulator: http://10.0.2.2:8000/api/
  // If using Chrome (web): http://127.0.0.1:8000/api/
  static const String baseUrl = "http://10.0.2.2:8000/api/v1/accounts/";

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
    final response = await http.post(
      Uri.parse('${baseUrl}register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'phone': phone,
        'first_name': firstName,
        'last_name': lastName,
        'password': password,
        'password2': password2,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['detail'] ?? 'Registration failed');
    }
  }

  // =========================================================
  // VERIFY EMAIL OTP
  // =========================================================
  static Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse('${baseUrl}verify-email/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['detail'] ?? 'Verification failed');
    }
  }

  // =========================================================
  // LOGIN
  // =========================================================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${baseUrl}token/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Invalid email or password');
    }
  }

  // =========================================================
  // FORGOT PASSWORD (Request OTP)
  // =========================================================
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('${baseUrl}forgot-password/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['detail'] ?? 'Failed to send OTP');
    }
  }

  // =========================================================
  // VERIFY PASSWORD OTP
  // =========================================================
  static Future<Map<String, dynamic>> verifyPasswordOTP({
    required String email,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse('${baseUrl}verify-password-otp/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['detail'] ?? 'OTP verification failed');
    }
  }

  // =========================================================
  // RESET PASSWORD (With reset token)
  // =========================================================
  static Future<Map<String, dynamic>> resetPassword({
    required String resetToken,
    required String password,
    required String password2,
  }) async {
    final response = await http.post(
      Uri.parse('${baseUrl}reset-password/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'reset_token': resetToken,
        'password': password,
        'password2': password2,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['detail'] ?? 'Password reset failed');
    }
  }

  // =========================================================
  // GET USER PROFILE (Requires JWT Token)
  // =========================================================
  static Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('${baseUrl}me/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  // =========================================================
  // UPDATE USER PROFILE (Requires JWT Token)
  // =========================================================
  static Future<Map<String, dynamic>> updateProfile({
    required String token,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    final response = await http.patch(
      Uri.parse('${baseUrl}me/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update profile');
    }
  }

  // =========================================================
  // GET ADDRESS (Requires JWT Token)
  // =========================================================
  static Future<Map<String, dynamic>> getAddress(String token) async {
    final response = await http.get(
      Uri.parse('${baseUrl}address/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // API returns a list, we take the first one if exists
      final data = jsonDecode(response.body);
      if (data is List && data.isNotEmpty) {
        return data[0];
      } else {
        return {};
      }
    } else {
      throw Exception('Failed to load address');
    }
  }

  // =========================================================
  // CREATE/UPDATE ADDRESS (Requires JWT Token)
  // =========================================================
  static Future<Map<String, dynamic>> saveAddress({
    required String token,
    required String firstName,
    required String lastName,
    required String company,
    required String address1,
    required String address2,
    required String city,
    required String postalCode,
    required String country,
    required String region,
  }) async {
    final response = await http.post(
      Uri.parse('${baseUrl}address/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'company': company,
        'address1': address1,
        'address2': address2,
        'city': city,
        'postal_code': postalCode,
        'country': country,
        'region': region,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to save address');
    }
  }

  // =========================================================
  // CHANGE PASSWORD (Requires JWT Token)
  // =========================================================
  static Future<Map<String, dynamic>> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
    required String newPassword2,
  }) async {
    final response = await http.post(
      Uri.parse('${baseUrl}change-password/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password2': newPassword2,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['detail'] ?? 'Password change failed');
    }
  }
}