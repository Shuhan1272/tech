import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/product.dart';
import '../models/category.dart';

/// Rewritten on the shared ApiClient/Dio instance instead of raw `http`.
/// This used to hardcode its own base URL (127.0.0.1, no version prefix)
/// which was BOTH a different host and a different API path than
/// auth_service.dart's (10.0.2.2, /api/v1/) — two services in one app
/// pointing at two different addresses. They now share one base URL.
class ProductService {
  static final Dio _dio = ApiClient.instance.dio;

  static Future<List<Product>> getProducts({
    String? category,
    String? brand,
    String? search,
    String? ordering,
    bool? isFeatured,
    int page = 1,
    int limit = 20,
    Map<String, String>? extraFilters,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'limit': limit};
    if (category != null) queryParams['category'] = category;
    if (brand != null) queryParams['brand'] = brand;
    if (search != null) queryParams['search'] = search;
    if (ordering != null) queryParams['ordering'] = ordering;
    if (isFeatured != null) queryParams['is_featured'] = isFeatured;
    if (extraFilters != null) queryParams.addAll(extraFilters);

    try {
      final response = await _dio.get('/products/', queryParameters: queryParams);
      final data = response.data;
      final List results = data is List ? data : (data['results'] as List? ?? []);
      return results.map((e) => Product.fromJson(Map<String, dynamic>.from(e))).toList();
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e));
    }
  }

  static Future<Product> getProductBySlug(String slug) async {
    try {
      final response = await _dio.get('/products/$slug/');
      return Product.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e));
    }
  }

  static Future<List<Product>> getFeaturedProducts({int limit = 10}) =>
      getProducts(isFeatured: true, limit: limit);

  static Future<List<Category>> getCategories({bool? isFeatured}) async {
    final queryParams = <String, dynamic>{};
    if (isFeatured != null) queryParams['is_featured'] = isFeatured;

    try {
      final response = await _dio.get('/categories/', queryParameters: queryParams);
      final data = response.data;
      final List results = data is List ? data : (data['results'] as List? ?? []);
      return results.map((e) => Category.fromJson(Map<String, dynamic>.from(e))).toList();
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e));
    }
  }

  static Future<List<Brand>> getBrands({String? category}) async {
    final queryParams = <String, dynamic>{};
    if (category != null) queryParams['categories'] = category;

    try {
      final response = await _dio.get('/brands/', queryParameters: queryParams);
      final data = response.data;
      final List results = data is List ? data : (data['results'] as List? ?? []);
      return results.map((e) => Brand.fromJson(Map<String, dynamic>.from(e))).toList();
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e));
    }
  }

  static Future<List<Product>> searchProducts(String query) => getProducts(search: query);
}
