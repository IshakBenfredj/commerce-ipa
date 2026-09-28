class BannerItem {
  final String id;
  final String title;
  final String? subtitle;
  final String? badge;
  final String? imageUrl;
  final String? linkUrl;
  final String? ctaText;
  final bool isActive;
  final int order;

  BannerItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.badge,
    this.imageUrl,
    this.linkUrl,
    this.ctaText,
    this.isActive = true,
    this.order = 0,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: json['_id'] ?? json['id'] ?? 'banner-${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      badge: json['badge'],
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? json['image'],
      linkUrl: json['linkUrl'] ?? json['link_url'] ?? json['link'],
      ctaText: json['ctaText'] ?? json['cta_text'],
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle ?? '',
    'badge': badge ?? '',
    'imageUrl': imageUrl ?? '',
    'image_url': imageUrl ?? '',
    'linkUrl': linkUrl ?? '',
    'link_url': linkUrl ?? '',
    'link': linkUrl ?? '',
    'ctaText': ctaText ?? '',
    'cta_text': ctaText ?? '',
    'isActive': isActive,
    'active': isActive,
    'order': order,
  };
}
