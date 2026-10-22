
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/product_service.dart';

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

  // Getters
  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
  List<Category> get categories => _categories;

  bool get isLoading => _isLoading;
  bool get isLoadingFeatured => _isLoadingFeatured;
  bool get isLoadingCategories => _isLoadingCategories;

  bool get hasMore => _hasMore;

  String get errorMessage => _errorMessage;
  String get categoriesError => _categoriesError;

  // True when categories have been received from the API.
  bool get hasRemoteCategories => _categories.isNotEmpty;

  // Only return API categories. No hardcoded fallback.
  List<Category> get displayCategories => _categories;

  // Fetch products with pagination and optional filters.
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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch featured products independently.
  Future<void> fetchFeaturedProducts() async {
    _isLoadingFeatured = true;
    notifyListeners();

    try {
      _featuredProducts =
          await ProductService.getFeaturedProducts(limit: 10);
    } catch (e) {
      _featuredProducts = [];
    } finally {
      _isLoadingFeatured = false;
      notifyListeners();
    }
  }

  // Fetch categories exclusively from the backend API.
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
      _categoriesError =
          e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  // Fetch one product by slug.
  Future<Product?> getProductBySlug(String slug) async {
    try {
      return await ProductService.getProductBySlug(slug);
    } catch (e) {
      return null;
    }
  }

  // Search products.
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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset product pagination and data.
  void resetProducts() {
    _products = [];
    _currentPage = 1;
    _hasMore = true;
    _errorMessage = '';
    notifyListeners();
  }
}
