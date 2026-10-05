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
class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  bool _isLoadingFeatured = false;
  bool _isLoadingCategories = false;
  String _errorMessage = '';
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

  /// Categories to render — real ones when loaded, the hardcoded popular
  /// list as a fallback. Centralized here because three different screens
  /// were each repeating this same `isNotEmpty ? real : fallback` check.
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

  Future<void> fetchCategories() async {
    _isLoadingCategories = true;
    notifyListeners();
    try {
      _categories = await ProductService.getCategories();
    } catch (_) {
      _categories = Category.getPopularCategories();
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
