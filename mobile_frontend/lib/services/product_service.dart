import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/category.dart';
import '../services/token_storage.dart';

class ProductService {
  // ⚠️ CHANGE THIS BASED ON YOUR TESTING ENVIRONMENT
  static const String baseUrl = "http://127.0.0.1:8000/api/";

  // =========================================================
  // GET ALL PRODUCTS (With Filters)
  // =========================================================
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
    final queryParams = <String, String>{};

    if (category != null) queryParams['category'] = category;
    if (brand != null) queryParams['brand'] = brand;
    if (search != null) queryParams['search'] = search;
    if (ordering != null) queryParams['ordering'] = ordering;
    if (isFeatured != null) queryParams['is_featured'] = isFeatured.toString();
    if (extraFilters != null) queryParams.addAll(extraFilters);

    queryParams['page'] = page.toString();
    queryParams['limit'] = limit.toString();

    final uri = Uri.parse('${baseUrl}products/').replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List? ?? data as List;
      return results.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }

  // =========================================================
  // GET PRODUCT BY SLUG (Detail)
  // =========================================================
  static Future<Product> getProductBySlug(String slug) async {
    final response = await http.get(
      Uri.parse('${baseUrl}products/$slug/'),
    );

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load product: ${response.statusCode}');
    }
  }

  // =========================================================
  // GET FEATURED PRODUCTS
  // =========================================================
  static Future<List<Product>> getFeaturedProducts({int limit = 10}) async {
    return getProducts(isFeatured: true, limit: limit);
  }

  // =========================================================
  // GET CATEGORIES
  // =========================================================
  static Future<List<Category>> getCategories({bool? isFeatured}) async {
    final queryParams = <String, String>{};
    if (isFeatured != null) queryParams['is_featured'] = isFeatured.toString();

    final uri = Uri.parse('${baseUrl}categories/').replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List? ?? data as List;
      return results.map((e) => Category.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load categories: ${response.statusCode}');
    }
  }

  // =========================================================
  // GET BRANDS
  // =========================================================
  static Future<List<Brand>> getBrands({String? category}) async {
    final queryParams = <String, String>{};
    if (category != null) queryParams['categories'] = category;

    final uri = Uri.parse('${baseUrl}brands/').replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List? ?? data as List;
      return results.map((e) => Brand.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load brands: ${response.statusCode}');
    }
  }

  // =========================================================
  // SEARCH PRODUCTS
  // =========================================================
  static Future<List<Product>> searchProducts(String query) async {
    return getProducts(search: query);
  }
}