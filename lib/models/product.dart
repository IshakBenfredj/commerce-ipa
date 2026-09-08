class ProductVariant {
  final String id;
  final String? name;
  final String? sku;
  final double? price;
  final int? stockQuantity;
  final Map<String, dynamic>? options;

  ProductVariant({
    required this.id,
    this.name,
    this.sku,
    this.price,
    this.stockQuantity,
    this.options,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? json['title'],
      sku: json['sku'],
      price: json['price'] != null ? (json['price']).toDouble() : null,
      stockQuantity: json['stock_quantity'] ?? json['stock'],
      options: json['options'] is Map<String, dynamic> ? json['options'] : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sku': sku,
    'price': price,
    'stock_quantity': stockQuantity,
    'options': options,
  };
}

class ProductPack {
  final int quantity;
  final double price;
  final String? label;
  final bool isPopular;

  ProductPack({
    required this.quantity,
    required this.price,
    this.label,
    this.isPopular = false,
  });

  factory ProductPack.fromJson(Map<String, dynamic> json) {
    return ProductPack(
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
      label: json['label'],
      isPopular: json['is_popular'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'quantity': quantity,
    'price': price,
    'label': label,
    'is_popular': isPopular,
  };
}

class Product {
  final String id;
  final String slug;
  final String? sku;
  final String? categoryId;
  final double price;
  final double? compareAtPrice;
  final int stockQuantity;
  final bool trackInventory;
  final bool isActive;
  final bool isFeatured;
  final String productType;
  final List<String> images;
  final String titleAr;
  final String? titleFr;
  final String descriptionAr;
  final String? descriptionFr;
  final List<ProductVariant> variants;
  final List<ProductPack> packs;

  Product({
    required this.id,
    required this.slug,
    this.sku,
    this.categoryId,
    required this.price,
    this.compareAtPrice,
    required this.stockQuantity,
    this.trackInventory = true,
    this.isActive = true,
    this.isFeatured = false,
    this.productType = 'normal',
    required this.images,
    required this.titleAr,
    this.titleFr,
    required this.descriptionAr,
    this.descriptionFr,
    this.variants = const [],
    this.packs = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> parsedImages = [];
    if (json['images'] != null && json['images'] is List) {
      parsedImages = (json['images'] as List).map((e) => e.toString()).toList();
    } else if (json['image_url'] != null) {
      parsedImages = [json['image_url'].toString()];
    }

    List<ProductVariant> parsedVariants = [];
    if (json['variants'] != null && json['variants'] is List) {
      parsedVariants = (json['variants'] as List)
          .map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
          .toList();
    }

    List<ProductPack> parsedPacks = [];
    if (json['pricing_packs'] != null && json['pricing_packs'] is List) {
      parsedPacks = (json['pricing_packs'] as List)
          .map((p) => ProductPack.fromJson(p as Map<String, dynamic>))
          .toList();
    }

    return Product(
      id: json['_id'] ?? json['id'] ?? '',
      slug: json['slug'] ?? '',
      sku: json['sku'],
      categoryId: json['category_id'] is Map
          ? json['category_id']['_id']
          : json['category_id']?.toString() ?? json['category_slug'],
      price: (json['price'] ?? 0).toDouble(),
      compareAtPrice: json['compare_at_price'] != null ? (json['compare_at_price']).toDouble() : null,
      stockQuantity: json['stock_quantity'] ?? 100,
      trackInventory: json['track_inventory'] ?? true,
      isActive: json['is_active'] ?? true,
      isFeatured: json['is_featured'] ?? false,
      productType: json['product_type'] ?? 'normal',
      images: parsedImages,
      titleAr: json['name_ar'] ?? json['title_ar'] ?? 'منتج',
      titleFr: json['name_fr'] ?? json['title_fr'],
      descriptionAr: json['description_ar'] ?? '',
      descriptionFr: json['description_fr'],
      variants: parsedVariants,
      packs: parsedPacks,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name_ar': titleAr,
    'name_fr': titleFr,
    'slug': slug,
    'sku': sku,
    'price': price,
    'compare_at_price': compareAtPrice,
    'stock_quantity': stockQuantity,
    'track_inventory': trackInventory,
    'is_active': isActive,
    'is_featured': isFeatured,
    'product_type': productType,
    'images': images,
    'description_ar': descriptionAr,
    'description_fr': descriptionFr,
    'category_id': categoryId,
    'pricing_packs': packs.map((p) => p.toJson()).toList(),
  };
}
