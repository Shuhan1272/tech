class Category {
  final int id;
  final String name;
  final String slug;
  final String? image;
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
      description: json['description'],
      filters: json['filters'] ?? {},
      isActive: json['is_active'] ?? true,
      isFeatured: json['is_featured'] ?? false,
      subCategories: json['sub_categories'] != null
          ? (json['sub_categories'] as List)
          .map((e) => Category.fromJson(e))
          .toList()
          : null,
      brands: json['brands'] != null
          ? (json['brands'] as List).map((e) => Brand.fromJson(e)).toList()
          : null,
    );
  }

  // Static categories for UI display (hardcoded based on your reference)
  static List<Category> getPopularCategories() {
    return [
      Category(id: 1, name: 'Trimmer', slug: 'trimmer', isFeatured: true),
      Category(id: 2, name: 'Mini UPS', slug: 'mini-ups', isFeatured: true),
      Category(id: 3, name: 'AC', slug: 'ac', isFeatured: true),
      Category(id: 4, name: 'Air Fryer', slug: 'air-fryer'),
      Category(id: 5, name: 'Drones', slug: 'drones'),
      Category(id: 6, name: 'Gimbal', slug: 'gimbal'),
      Category(id: 7, name: 'Tablet', slug: 'tablet'),
      Category(id: 8, name: 'TV', slug: 'tv'),
      Category(id: 9, name: 'Fridge', slug: 'fridge'),
      Category(id: 10, name: 'Phone', slug: 'phone'),
      Category(id: 11, name: 'Mobile Accessories', slug: 'mobile-accessories'),
      Category(id: 12, name: 'Smart Watch', slug: 'smart-watch'),
      Category(id: 13, name: 'Earbuds', slug: 'earbuds'),
      Category(id: 14, name: 'Portable WiFi Camera', slug: 'portable-wifi-camera'),
      Category(id: 15, name: 'Portable SSD', slug: 'portable-ssd'),
    ];
  }

  // Get category icon based on name (for UI display)
  String get icon {
    final icons = {
      'Trimmer': '⚡',
      'Mini UPS': '🔋',
      'AC': '❄️',
      'Air Fryer': '🍟',
      'Drones': '🛸',
      'Gimbal': '📷',
      'Tablet': '📱',
      'TV': '📺',
      'Fridge': '🧊',
      'Phone': '📱',
      'Mobile Accessories': '🔌',
      'Smart Watch': '⌚',
      'Earbuds': '🎧',
      'Portable WiFi Camera': '📹',
      'Portable SSD': '💾',
    };
    return icons[name] ?? '📦';
  }
}

// =========================================================
// Brand Model
// =========================================================

class Brand {
  final int id;
  final String name;
  final String slug;
  final String? image;
  final String? description;
  final bool isActive;
  final List<int>? categories;

  Brand({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
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
      description: json['description'],
      isActive: json['is_active'] ?? true,
      categories: json['categories'] != null
          ? List<int>.from(json['categories'])
          : null,
    );
  }
}