import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../core/constants.dart';
import '../models/product.dart';
import '../models/category.dart';

/// Rewritten on the shared ApiClient/Dio instance instead of raw `http`.
/// This used to hardcode its own base URL (127.0.0.1, no version prefix)
/// which was BOTH a different host and a different API path than
/// auth_service.dart's (10.0.2.2, /api/v1/) — two services in one app
/// pointing at two different addresses. They now share one base URL.
///
/// FIXED (categories/brands were never reaching the backend):
/// the categories and brands routers live inside the products app, so the
/// endpoints are /products/categories/ and /products/brands/ — this file
/// was requesting /categories/ and /brands/, which is a 404 on this
/// backend. Every failure was swallowed by ProductProvider (which fell
/// back to a hardcoded list), so the UI *looked* fine while showing
/// categories that don't exist in the database. The paths now come from
/// ApiConstants so they can't drift again.
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
      final response = await _dio.get(ApiConstants.productsPath, queryParameters: queryParams);
      final data = response.data;
      final List results = data is List ? data : (data['results'] as List? ?? []);
      return results.map((e) => Product.fromJson(Map<String, dynamic>.from(e))).toList();
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e));
    }
  }

  static Future<Product> getProductBySlug(String slug) async {
    try {
      final response = await _dio.get('${ApiConstants.productsPath}$slug/');
      return Product.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e));
    }
  }

  static Future<List<Product>> getFeaturedProducts({int limit = 10}) =>
      getProducts(isFeatured: true, limit: limit);

  /// GET /products/categories/
  ///
  /// The backend's CategoryViewSet returns TOP-LEVEL categories only
  /// (queryset is filtered to parent=None), and each one already carries
  /// its `brands` and `sub_categories`. It is NOT paginated, but the
  /// parser below accepts both a bare list and a paginated
  /// `{"results": [...]}` body so it keeps working if pagination is ever
  /// switched on.
  static Future<List<Category>> getCategories({bool? isFeatured}) async {
    final queryParams = <String, dynamic>{};
    if (isFeatured != null) queryParams['is_featured'] = isFeatured;

    try {
      final response = await _dio.get(ApiConstants.categoriesPath, queryParameters: queryParams);
      final data = response.data;
      final List results = data is List ? data : (data['results'] as List? ?? []);
      return results.map((e) => Category.fromJson(Map<String, dynamic>.from(e))).toList();
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e));
    }
  }

  /// GET /products/products/?category=slug
  /// Convenience wrapper used where a screen only needs "products in this
  /// category" and nothing else. The backend matches the slug against the
  /// product's own category OR its parent, so a top-level category returns
  /// everything filed under its sub-categories too.
  static Future<List<Product>> getProductsByCategory(
      String categorySlug, {
        int page = 1,
        int limit = 20,
        String? ordering,
      }) =>
      getProducts(
        category: categorySlug,
        page: page,
        limit: limit,
        ordering: ordering,
      );

  /// GET /products/brands/  (optionally `?categories=<slug>`, which the
  /// backend's BrandFilter matches by category slug)
  static Future<List<Brand>> getBrands({String? category}) async {
    final queryParams = <String, dynamic>{};
    if (category != null) queryParams['categories'] = category;

    try {
      final response = await _dio.get(ApiConstants.brandsPath, queryParameters: queryParams);
      final data = response.data;
      final List results = data is List ? data : (data['results'] as List? ?? []);
      return results.map((e) => Brand.fromJson(Map<String, dynamic>.from(e))).toList();
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e));
    }
  }

  static Future<List<Product>> searchProducts(String query) => getProducts(search: query);
}