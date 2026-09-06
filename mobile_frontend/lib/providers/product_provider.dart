import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMore = true;

  // Getters
  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String get errorMessage => _errorMessage;

  // =========================================================
  // FETCH PRODUCTS (With Filters)
  // =========================================================
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

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================================================
  // FETCH FEATURED PRODUCTS
  // =========================================================
  Future<void> fetchFeaturedProducts() async {
    try {
      _featuredProducts = await ProductService.getFeaturedProducts(limit: 10);
      notifyListeners();
    } catch (e) {
      // Silently fail - featured products are optional
      _featuredProducts = [];
    }
  }

  // =========================================================
  // FETCH CATEGORIES
  // =========================================================
  Future<void> fetchCategories() async {
    try {
      _categories = await ProductService.getCategories();
      notifyListeners();
    } catch (e) {
      // Fallback to hardcoded categories if API fails
      _categories = Category.getPopularCategories();
      notifyListeners();
    }
  }

  // =========================================================
  // GET PRODUCT BY SLUG
  // =========================================================
  Future<Product?> getProductBySlug(String slug) async {
    try {
      return await ProductService.getProductBySlug(slug);
    } catch (e) {
      return null;
    }
  }

  // =========================================================
  // SEARCH PRODUCTS
  // =========================================================
  Future<void> searchProducts(String query) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _products = await ProductService.searchProducts(query);
      _hasMore = false; // Search doesn't paginate for now
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

// =========================================================
// LOAD MOCK DATA (Fallback for testing without backend)
// =========================================================
  void loadMockData() {
    _products = Product.getMockProducts();
    _featuredProducts = Product.getFeaturedProducts();
    _categories = Category.getPopularCategories();
    notifyListeners();
  }

  // =========================================================
  // RESET PRODUCTS
  // =========================================================
  void resetProducts() {
    _products = [];
    _currentPage = 1;
    _hasMore = true;
    _errorMessage = '';
    notifyListeners();
  }
}