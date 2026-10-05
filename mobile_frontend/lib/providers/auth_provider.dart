import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/token_storage.dart';

/// Expanded from the original: forgot_password_screen.dart and
/// reset_password_screen.dart used to call AuthService directly rather
/// than going through this provider, so those two screens had a
/// completely different loading/error pattern than every other auth
/// screen. Every auth action now flows through here consistently.
///
/// checkAuthStatus() also no longer force-logs-out on any profile-fetch
/// failure — ApiClient's interceptor transparently refreshes an expired
/// access token and retries, so this catch block is only reached when the
/// refresh token itself is gone or invalid, which is the only time
/// logging out is actually correct.
class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;
  String? errorMessage;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;

  String get displayName {
    final first = (_user?['first_name'] ?? '').toString().trim();
    final last = (_user?['last_name'] ?? '').toString().trim();
    final full = '$first $last'.trim();
    return full.isEmpty ? (_user?['email'] ?? 'TechNest User').toString() : full;
  }

  String get initial {
    final first = (_user?['first_name'] ?? '').toString().trim();
    if (first.isNotEmpty) return first[0].toUpperCase();
    final email = (_user?['email'] ?? '').toString().trim();
    return email.isNotEmpty ? email[0].toUpperCase() : 'U';
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    final loggedIn = await TokenStorage.isLoggedIn();
    if (!loggedIn) {
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _user = await AuthService.getProfile();
      _isAuthenticated = true;
    } catch (_) {
      await TokenStorage.clearTokens();
      _isAuthenticated = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> register({
    required String email,
    required String phone,
    required String firstName,
    required String lastName,
    required String password,
    required String password2,
  }) {
    return _runGuarded(() async {
      await AuthService.register(
        email: email,
        phone: phone,
        firstName: firstName,
        lastName: lastName,
        password: password,
        password2: password2,
      );
    });
  }

  /// Also logs the user in — verify-email returns tokens on success.
  Future<bool> verifyEmail({required String email, required String otp}) {
    return _runGuarded(() async {
      final response = await AuthService.verifyEmail(email: email, otp: otp);
      await TokenStorage.saveTokens(access: response['access'], refresh: response['refresh']);
      _user = Map<String, dynamic>.from(response['user']);
      _isAuthenticated = true;
    });
  }

  Future<bool> login({required String email, required String password}) {
    return _runGuarded(() async {
      final response = await AuthService.login(email: email, password: password);
      await TokenStorage.saveTokens(access: response['access'], refresh: response['refresh']);
      _user = await AuthService.getProfile();
      _isAuthenticated = true;
    });
  }

  Future<bool> forgotPassword({required String email}) {
    return _runGuarded(() => AuthService.forgotPassword(email: email));
  }

  /// Returns the reset_token on success (ResetPasswordScreen needs it),
  /// or null on failure — check errorMessage in that case.
  Future<String?> verifyPasswordOtp({required String email, required String otp}) async {
    String? token;
    final success = await _runGuarded(() async {
      final response = await AuthService.verifyPasswordOTP(email: email, otp: otp);
      token = response['reset_token'];
    });
    return success ? token : null;
  }

  Future<bool> resetPassword({
    required String resetToken,
    required String password,
    required String password2,
  }) {
    return _runGuarded(() => AuthService.resetPassword(
      resetToken: resetToken,
      password: password,
      password2: password2,
    ));
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
  }) {
    return _runGuarded(() async {
      _user = await AuthService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );
    });
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPassword2,
  }) {
    return _runGuarded(() => AuthService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      newPassword2: newPassword2,
    ));
  }

  Future<void> logout() async {
    await TokenStorage.clearTokens();
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }

  /// Shared wrapper: toggles isLoading, clears/sets errorMessage, and
  /// converts a thrown Exception into a message screens can display.
  Future<bool> _runGuarded(Future<void> Function() action) async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
