/// Safely converts a JSON value to a double whether the backend sent a
/// number or a string.
///
/// This matters because DRF's DecimalField — almost certainly what
/// price/discount_percentage/etc. are, for correct money math —
/// serializes to JSON as a STRING by default (e.g. "45.99", not 45.99),
/// specifically to avoid floating-point precision loss. The original
/// code did `(json['price'] ?? 0.0).toDouble()`, which throws at runtime
/// the moment the backend sends a string, because String has no
/// .toDouble(). That was a real crash waiting to happen the first time
/// real backend data (rather than the mock data) reached these models.
double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

class Product {
  final int id;
  final String name;
  final String slug;
  final String category;
  final String brand;
  final String description;
  final String? image;
  final Map<String, dynamic> keyFeature;
  final Map<String, dynamic> specification;
  final List<String> colors;
  final bool isActive;
  final bool isFeatured;
  final ProductVariant? defaultVariant;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.category,
    required this.brand,
    required this.description,
    this.image,
    required this.keyFeature,
    required this.specification,
    required this.colors,
    required this.isActive,
    required this.isFeatured,
    this.defaultVariant,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _toInt(json['id']),
      name: json['name'] ?? 'Unknown Product',
      slug: json['slug'] ?? '',
      // category/brand can arrive as a nested object ({"name": "..."})
      // or a plain string depending on the serializer — handle both, so
      // real data doesn't silently render as "Uncategorized".
      category: _extractName(json['category']) ?? 'Uncategorized',
      brand: _extractName(json['brand']) ?? 'Unknown Brand',
      description: json['description'] ?? '',
      // NEW: the app never parsed an image field at all before, which is
      // why every product fell back to an external placeholder service.
      image: json['image'] ?? json['thumbnail'],
      keyFeature: Map<String, dynamic>.from(json['key_feature'] ?? {}),
      specification: Map<String, dynamic>.from(json['specification'] ?? {}),
      colors: List<String>.from(json['colors'] ?? []),
      isActive: json['is_active'] ?? true,
      isFeatured: json['is_featured'] ?? false,
      defaultVariant: json['default_variant'] != null
          ? ProductVariant.fromJson(Map<String, dynamic>.from(json['default_variant']))
          : null,
    );
  }

  static String? _extractName(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map) return value['name']?.toString();
    return value.toString();
  }

  /// Mock data — kept only as a graceful fallback, never the primary
  /// source.
  static List<Product> getMockProducts() {
    return [
      Product(
        id: 1,
        name: 'Mini UPS for Router',
        slug: 'mini-ups',
        category: 'Electronics',
        brand: 'MaxGreen',
        description: 'DU-B8000 | DU-B10400',
        keyFeature: const {},
        specification: const {},
        colors: const ['Black', 'White'],
        isActive: true,
        isFeatured: true,
        defaultVariant: ProductVariant(
          id: 1, product: 1, sku: 'UPS-001', options: const {},
          price: 45.99, discountPercentage: 15, discountedPrice: 39.09,
          savedPrice: 6.90, stock: 25, isDefault: true, isActive: true,
        ),
      ),
      Product(
        id: 2,
        name: 'Wireless Trimmer',
        slug: 'wireless-trimmer',
        category: 'Accessories',
        brand: 'Philips',
        description: 'Cordless, Waterproof',
        keyFeature: const {},
        specification: const {},
        colors: const ['Black'],
        isActive: true,
        isFeatured: true,
        defaultVariant: ProductVariant(
          id: 2, product: 2, sku: 'TRIM-001', options: const {},
          price: 29.99, discountPercentage: 0, discountedPrice: 29.99,
          savedPrice: 0, stock: 40, isDefault: true, isActive: true,
        ),
      ),
    ];
  }

  static List<Product> getFeaturedProducts() =>
      getMockProducts().where((p) => p.isFeatured).toList();

  double get displayPrice => defaultVariant?.discountedPrice ?? defaultVariant?.price ?? 0.0;
  double get originalPrice => defaultVariant?.price ?? 0.0;
  bool get isOnSale => (defaultVariant?.discountPercentage ?? 0) > 0;
  double get discountPercentage => defaultVariant?.discountPercentage ?? 0.0;
  int get stock => defaultVariant?.stock ?? 0;
  bool get inStock => stock > 0;
}

// =========================================================
// Product Variant Model
// =========================================================

class ProductVariant {
  final int id;
  final int product;
  final String sku;
  final Map<String, dynamic> options;
  final double price;
  final double discountPercentage;
  final double discountedPrice;
  final double savedPrice;
  final int stock;
  final bool isDefault;
  final bool isActive;

  ProductVariant({
    required this.id,
    required this.product,
    required this.sku,
    required this.options,
    required this.price,
    required this.discountPercentage,
    required this.discountedPrice,
    required this.savedPrice,
    required this.stock,
    required this.isDefault,
    required this.isActive,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: _toInt(json['id']),
      product: _toInt(json['product']),
      sku: json['sku'] ?? '',
      options: Map<String, dynamic>.from(json['options'] ?? {}),
      price: _toDouble(json['price']),
      discountPercentage: _toDouble(json['discount_percentage']),
      discountedPrice: _toDouble(json['discounted_price']),
      savedPrice: _toDouble(json['saved_price']),
      stock: _toInt(json['stock']),
      isDefault: json['is_default'] ?? false,
      isActive: json['is_active'] ?? true,
    );
  }
}
