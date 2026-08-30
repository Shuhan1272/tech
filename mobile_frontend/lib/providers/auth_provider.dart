import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/token_storage.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;

  // Check login status on app start
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    final token = await TokenStorage.getAccessToken();
    if (token != null) {
      _isAuthenticated = true;
      // Optionally fetch user profile
      try {
        _user = await AuthService.getProfile(token);
      } catch (e) {
        // Token might be expired
        await logout();
      }
    } else {
      _isAuthenticated = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Register
  Future<void> register({
    required String email,
    required String phone,
    required String firstName,
    required String lastName,
    required String password,
    required String password2,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await AuthService.register(
        email: email,
        phone: phone,
        firstName: firstName,
        lastName: lastName,
        password: password,
        password2: password2,
      );
      // Registration successful, user now needs to verify OTP
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Verify Email OTP (This logs the user in automatically)
  Future<void> verifyEmail({
    required String email,
    required String otp,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await AuthService.verifyEmail(
        email: email,
        otp: otp,
      );

      // Save tokens and user data
      await TokenStorage.saveTokens(
        access: response['access'],
        refresh: response['refresh'],
        user: response['user'],
      );

      _isAuthenticated = true;
      _user = response['user'];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Login
  Future<void> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await AuthService.login(
        email: email,
        password: password,
      );

      // Save tokens
      await TokenStorage.saveTokens(
        access: response['access'],
        refresh: response['refresh'],
      );

      // Fetch user profile
      final userData = await AuthService.getProfile(response['access']);
      _user = userData;

      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    await TokenStorage.clearTokens();
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }

  // Update profile (local)
  void updateUser(Map<String, dynamic> updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }
}