class Category {
  final String id;
  final String nameAr;
  final String? nameFr;
  final String slug;
  final bool isActive;
  final int sortOrder;
  final String? imageUrl;

  Category({
    required this.id,
    required this.nameAr,
    this.nameFr,
    required this.slug,
    this.isActive = true,
    this.sortOrder = 1,
    this.imageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? json['id'] ?? '',
      nameAr: json['name_ar'] ?? json['name'] ?? 'قسم',
      nameFr: json['name_fr'],
      slug: json['slug'] ?? '',
      isActive: json['is_active'] ?? true,
      sortOrder: json['display_order'] ?? json['sort_order'] ?? 1,
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name_ar': nameAr,
    'name_fr': nameFr,
    'slug': slug,
    'is_active': isActive,
    'display_order': sortOrder,
    'image_url': imageUrl,
  };
}
