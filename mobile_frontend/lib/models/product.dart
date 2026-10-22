
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

bool _toBool(dynamic value, {bool defaultValue = false}) {
  if (value == null) return defaultValue;
  if (value is bool) return value;
  if (value is num) return value != 0;
  return value.toString().toLowerCase() == 'true';
}

Map<String, dynamic> _toMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return {};
}

String? _extractName(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is Map) return value['name']?.toString();
  return value.toString();
}

// =========================================================
// Product Image Model
// =========================================================

class ProductImage {
  final int id;
  final String? image;
  final String? imageUrl;
  final String altText;
  final bool isPrimary;
  final int displayOrder;

  const ProductImage({
    required this.id,
    this.image,
    this.imageUrl,
    required this.altText,
    required this.isPrimary,
    required this.displayOrder,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: _toInt(json['id']),
      image: json['image']?.toString(),
      imageUrl: json['image_url']?.toString(),
      altText: json['alt_text']?.toString() ?? '',
      isPrimary: _toBool(json['is_primary']),
      displayOrder: _toInt(json['display_order']),
    );
  }

  /// Prefer image_url; if unavailable, use image.
  String? get displayUrl {
    final url = imageUrl?.trim();

    if (url != null && url.isNotEmpty) {
      return url;
    }

    final storedImage = image?.trim();

    if (storedImage != null && storedImage.isNotEmpty) {
      return storedImage;
    }

    return null;
  }
}

// =========================================================
// Product Model
// =========================================================

class Product {
  final int id;
  final String name;
  final String slug;
  final String category;
  final String brand;
  final String description;
  final List<ProductImage> images;
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
    List<ProductImage>? images,
    required this.keyFeature,
    required this.specification,
    required this.colors,
    required this.isActive,
    required this.isFeatured,
    this.defaultVariant,
  }) : images = images ?? [];

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];

    final List<ProductImage> parsedImages = rawImages is List
        ? rawImages
            .whereType<Map>()
            .map(
              (item) => ProductImage.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
        : <ProductImage>[];

    // Primary image first, then sort by display order.
    parsedImages.sort((a, b) {
      if (a.isPrimary != b.isPrimary) {
        return a.isPrimary ? -1 : 1;
      }

      return a.displayOrder.compareTo(b.displayOrder);
    });

    final rawColors = json['colors'];

    return Product(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? 'Unknown Product',
      slug: json['slug']?.toString() ?? '',
      category: _extractName(json['category']) ?? 'Uncategorized',
      brand: _extractName(json['brand']) ?? 'Unknown Brand',
      description: json['description']?.toString() ?? '',
      images: parsedImages,
      keyFeature: _toMap(json['key_feature']),
      specification: _toMap(json['specification']),
      colors: rawColors is List
          ? rawColors.map((value) => value.toString()).toList()
          : <String>[],
      isActive: _toBool(json['is_active'], defaultValue: true),
      isFeatured: _toBool(json['is_featured']),
      defaultVariant: json['default_variant'] is Map
          ? ProductVariant.fromJson(
              Map<String, dynamic>.from(json['default_variant']),
            )
          : null,
    );
  }

  /// Returns the primary image, or the first available image.
  ProductImage? get primaryImage {
    if (images.isEmpty) return null;

    for (final image in images) {
      if (image.isPrimary) return image;
    }

    return images.first;
  }

  /// URL used by widgets that display a single product image.
  String? get imageUrl => primaryImage?.displayUrl;

  double get displayPrice =>
      defaultVariant?.discountedPrice ?? defaultVariant?.price ?? 0.0;

  double get originalPrice => defaultVariant?.price ?? 0.0;

  bool get isOnSale =>
      (defaultVariant?.discountPercentage ?? 0.0) > 0;

  double get discountPercentage =>
      defaultVariant?.discountPercentage ?? 0.0;

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
      sku: json['sku']?.toString() ?? '',
      options: _toMap(json['options']),
      price: _toDouble(json['price']),
      discountPercentage: _toDouble(json['discount_percentage']),
      discountedPrice: _toDouble(json['discounted_price']),
      savedPrice: _toDouble(json['saved_price']),
      stock: _toInt(json['stock']),
      isDefault: _toBool(json['is_default']),
      isActive: _toBool(json['is_active'], defaultValue: true),
    );
  }
}
