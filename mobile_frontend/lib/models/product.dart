class Product {
  final int id;
  final String name;
  final String slug;
  final String category;
  final String brand;
  final String description;
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
    required this.keyFeature,
    required this.specification,
    required this.colors,
    required this.isActive,
    required this.isFeatured,
    this.defaultVariant,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Product',
      slug: json['slug'] ?? '',
      category: json['category'] ?? 'Uncategorized',
      brand: json['brand'] ?? 'Unknown Brand',
      description: json['description'] ?? '',
      keyFeature: json['key_feature'] ?? {},
      specification: json['specification'] ?? {},
      colors: List<String>.from(json['colors'] ?? []),
      isActive: json['is_active'] ?? true,
      isFeatured: json['is_featured'] ?? false,
      defaultVariant: json['default_variant'] != null
          ? ProductVariant.fromJson(json['default_variant'])
          : null,
    );
  }

  // Mock data for testing
  static List<Product> getMockProducts() {
    return [
      Product(
        id: 1,
        name: 'Mini UPS for Router',
        slug: 'mini-ups',
        category: 'Electronics',
        brand: 'MaxGreen',
        description: 'DU-B8000 | DU-B10400',
        keyFeature: {},
        specification: {},
        colors: ['Black', 'White'],
        isActive: true,
        isFeatured: true,
        defaultVariant: ProductVariant(
          id: 1,
          product: 1,
          sku: 'UPS-001',
          options: {},
          price: 45.99,
          discountPercentage: 15,
          discountedPrice: 39.09,
          savedPrice: 6.90,
          stock: 25,
          isDefault: true,
          isActive: true,
        ),
      ),
      Product(
        id: 2,
        name: 'Wireless Trimmer',
        slug: 'wireless-trimmer',
        category: 'Accessories',
        brand: 'Philips',
        description: 'Cordless, Waterproof',
        keyFeature: {},
        specification: {},
        colors: ['Black'],
        isActive: true,
        isFeatured: true,
        defaultVariant: ProductVariant(
          id: 2,
          product: 2,
          sku: 'TRIM-001',
          options: {},
          price: 29.99,
          discountPercentage: 0,
          discountedPrice: 29.99,
          savedPrice: 0,
          stock: 40,
          isDefault: true,
          isActive: true,
        ),
      ),
    ];
  }

  static List<Product> getFeaturedProducts() {
    return getMockProducts().where((p) => p.isFeatured).toList();
  }

  double get displayPrice => defaultVariant?.discountedPrice ?? defaultVariant?.price ?? 0.0;
  double get originalPrice => defaultVariant?.price ?? 0.0;
  bool get isOnSale {
    final discount = defaultVariant?.discountPercentage ?? 0;
    return discount > 0;
  }
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
      id: json['id'] ?? 0,
      product: json['product'] ?? 0,
      sku: json['sku'] ?? '',
      options: json['options'] ?? {},
      price: (json['price'] ?? 0.0).toDouble(),
      discountPercentage: (json['discount_percentage'] ?? 0.0).toDouble(),
      discountedPrice: (json['discounted_price'] ?? 0.0).toDouble(),
      savedPrice: (json['saved_price'] ?? 0.0).toDouble(),
      stock: json['stock'] ?? 0,
      isDefault: json['is_default'] ?? false,
      isActive: json['is_active'] ?? true,
    );
  }
}