import 'package:dio/dio.dart';
import 'constants.dart';
import '../services/token_storage.dart';

/// A single shared Dio instance for the whole app.
///
/// The previous services (auth_service.dart, product_service.dart) each
/// used the raw `http` package directly, manually building
/// `Authorization: Bearer <token>` headers in every single method and
/// passing a `token` parameter through the provider into every call.
/// Two real problems came from that:
///
///  1. There was no token refresh anywhere in the app. Once the access
///     token expired (typically ~1 hour), every authenticated call would
///     start failing and the user would have to log in again.
///  2. auth_service.dart and product_service.dart each hardcoded a
///     different base URL — different host AND different API prefix —
///     which is a real bug if both hit the same backend.
///
/// Centralizing fixes both: one base URL, one place that attaches the
/// token, and one interceptor that transparently refreshes an expired
/// token and retries — so services/providers no longer need to know a
/// token exists at all.
class ApiClient {
  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenStorage.getAccessToken();
        if (token != null && !options.path.contains('/accounts/token/')) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        final isUnauthorized = error.response?.statusCode == 401;
        final isRefreshCall = error.requestOptions.path.contains('/accounts/token/refresh/');

        if (isUnauthorized && !isRefreshCall) {
          final refreshed = await _tryRefreshToken();
          if (refreshed) {
            final retryOptions = error.requestOptions;
            final newToken = await TokenStorage.getAccessToken();
            retryOptions.headers['Authorization'] = 'Bearer $newToken';
            try {
              final response = await dio.fetch(retryOptions);
              return handler.resolve(response);
            } catch (_) {
              return handler.next(error);
            }
          }
        }
        return handler.next(error);
      },
    ));
  }

  static final ApiClient instance = ApiClient._internal();
  late final Dio dio;

  Future<bool> _tryRefreshToken() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      // A plain Dio with no interceptors, so a failed refresh can't
      // trigger this same logic again in a loop.
      final plainDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      final response = await plainDio.post('/accounts/token/refresh/', data: {'refresh': refreshToken});
      await TokenStorage.saveAccessToken(response.data['access']);
      return true;
    } catch (_) {
      await TokenStorage.clearTokens();
      return false;
    }
  }

  /// Turns a DioException into a plain readable message — handles DRF's
  /// {"field": ["msg"]}, {"field": "msg"}, and {"detail": "msg"} shapes.
  static String errorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        for (final entry in data.entries) {
          final value = entry.value;
          if (value is List && value.isNotEmpty) return value.first.toString();
          if (value is String) return value;
        }
      }
      if (data is String && data.isNotEmpty) return data;
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.connectionError) {
        return 'Could not reach the server. Check your connection and try again.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
