import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Rewritten to use flutter_secure_storage instead of SharedPreferences.
/// SharedPreferences stores everything in a plain, unencrypted file on
/// the device — fine for UI prefs, but JWTs are effectively a password
/// replacement and shouldn't sit there in plain text.
///
/// The old version also tried to persist the user profile with
/// `user.toString()`, which produces Dart's debug map representation
/// (e.g. "{id: 3, email: ...}"), not JSON — it could never have been
/// parsed back. Nothing read it either, since AuthProvider always
/// re-fetches the profile from /me/ on startup. Dropped rather than left
/// in as dead, broken code.
class TokenStorage {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _storage = FlutterSecureStorage();

  static Future<void> saveTokens({required String access, required String refresh}) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  static Future<void> saveAccessToken(String access) async {
    await _storage.write(key: _accessKey, value: access);
  }

  static Future<String?> getAccessToken() => _storage.read(key: _accessKey);
  static Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);

  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null;
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
