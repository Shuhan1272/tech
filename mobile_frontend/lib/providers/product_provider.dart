import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/product_service.dart';

/// Added separate isLoadingFeatured/isLoadingCategories flags.
///
/// Previously there was one shared `isLoading` flag driven by the main
/// product fetch. HomeScreen used that same flag to decide whether to
/// show a spinner over the *featured products* row — but
/// fetchFeaturedProducts() never touched isLoading at all. So if the main
/// fetch finished first, the spinner vanished and the row briefly showed
/// stale/empty content before the real featured products arrived.
/// Separate flags remove that flicker.
///
/// FIXED (categories are now genuinely backend-driven):
/// fetchCategories() used to swallow every error and drop the app onto
/// the hardcoded Category.getPopularCategories() list, and it was calling
/// an endpoint (/categories/) that doesn't exist on this backend — so the
/// real list never loaded and nobody could tell why. The error is now
/// kept in `categoriesError` so screens can surface a Retry instead of
/// pretending everything is fine.
class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  bool _isLoadingFeatured = false;
  bool _isLoadingCategories = false;
  String _errorMessage = '';
  String _categoriesError = '';
  int _currentPage = 1;
  bool _hasMore = true;

  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isLoadingFeatured => _isLoadingFeatured;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get hasMore => _hasMore;
  String get errorMessage => _errorMessage;

  /// Non-empty only when the last categories request failed. Screens use
  /// it to offer a retry — the UI still shows the fallback list so the
  /// home screen is never empty, but it no longer hides the problem.
  String get categoriesError => _categoriesError;

  /// True once real categories have arrived from the API (i.e. what is on
  /// screen is the backend's data, not the local fallback list).
  bool get hasRemoteCategories => _categories.isNotEmpty;

  /// Categories to render — real ones when loaded, the hardcoded popular
  /// list as an offline fallback. Centralized here because three different
  /// screens were each repeating this same `isNotEmpty ? real : fallback`
  /// check.
  List<Category> get displayCategories =>
      _categories.isNotEmpty ? _categories : Category.getPopularCategories();

  Future<void> fetchProducts({
    String? category,
    String? brand,
    String? search,
    String? ordering,
    bool? isFeatured,
    bool refresh = false,
  }) async {
    if (refresh) {
      _products = [];
      _currentPage = 1;
      _hasMore = true;
    }

    if (!_hasMore) return;

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final newProducts = await ProductService.getProducts(
        category: category,
        brand: brand,
        search: search,
        ordering: ordering,
        isFeatured: isFeatured,
        page: _currentPage,
      );

      if (newProducts.isEmpty) {
        _hasMore = false;
      } else {
        _products.addAll(newProducts);
        _currentPage++;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _hasMore = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchFeaturedProducts() async {
    _isLoadingFeatured = true;
    notifyListeners();
    try {
      _featuredProducts = await ProductService.getFeaturedProducts(limit: 10);
    } catch (_) {
      _featuredProducts = [];
    }
    _isLoadingFeatured = false;
    notifyListeners();
  }

  /// Loads the real category tree from the backend
  /// (GET /products/categories/). On failure the previously loaded list
  /// is kept (and the error is exposed through categoriesError) rather
  /// than silently replaced with hardcoded data.
  Future<void> fetchCategories() async {
    _isLoadingCategories = true;
    _categoriesError = '';
    notifyListeners();
    try {
      final fetched = await ProductService.getCategories();
      _categories = fetched;
      if (fetched.isEmpty) {
        _categoriesError = 'No categories available';
      }
    } catch (e) {
      _categoriesError = e.toString().replaceFirst('Exception: ', '');
    }
    _isLoadingCategories = false;
    notifyListeners();
  }

  Future<Product?> getProductBySlug(String slug) async {
    try {
      return await ProductService.getProductBySlug(slug);
    } catch (_) {
      return null;
    }
  }

  Future<void> searchProducts(String query) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _products = await ProductService.searchProducts(query);
      _hasMore = false;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _products = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void loadMockData() {
    _products = Product.getMockProducts();
    _featuredProducts = Product.getFeaturedProducts();
    _categories = Category.getPopularCategories();
    notifyListeners();
  }

  void resetProducts() {
    _products = [];
    _currentPage = 1;
    _hasMore = true;
    _errorMessage = '';
    notifyListeners();
  }
}