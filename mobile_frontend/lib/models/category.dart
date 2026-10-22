class Category {
  final int id;
  final String name;
  final String slug;

  final String? image;
  final String? image_url;
  final String? description;

  final Map<String, dynamic> filters;

  final bool isActive;
  final bool isFeatured;

  final List<Category>? subCategories;
  final List<Brand>? brands;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
    this.image_url,
    this.description,
    this.filters = const {},
    this.isActive = true,
    this.isFeatured = false,
    this.subCategories,
    this.brands,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Uncategorized',
      slug: json['slug'] ?? '',
      image: json['image'],
      image_url: json['image_url'],
      description: json['description'],
      filters: Map<String, dynamic>.from(json['filters'] ?? {}),
      isActive: json['is_active'] ?? true,
      isFeatured: json['is_featured'] ?? false,
      subCategories: json['sub_categories'] != null
          ? (json['sub_categories'] as List)
              .map(
                (e) => Category.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList()
          : null,
      brands: json['brands'] != null
          ? (json['brands'] as List)
              .map(
                (e) => Brand.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList()
          : null,
    );
  }
}

// Brand model
class Brand {
  final int id;
  final String name;
  final String slug;

  final String? image;
  final String? image_url;
  final String? description;

  final bool isActive;
  final List<int>? categories;

  Brand({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
    this.image_url,
    this.description,
    this.isActive = true,
    this.categories,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Brand',
      slug: json['slug'] ?? '',
      image: json['image'],
      image_url: json['image_url'],
      description: json['description'],
      isActive: json['is_active'] ?? true,
      categories: json['categories'] != null
          ? List<int>.from(json['categories'])
          : null,
    );
  }
}
