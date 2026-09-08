import 'banner.dart';
import 'wilaya_tarif.dart';

class CustomColors {
  final String primary;
  final String secondary;
  final String accent;

  CustomColors({
    this.primary = '#1C1B1F',
    this.secondary = '#5C6AC4',
    this.accent = '#5C6AC4',
  });

  factory CustomColors.fromJson(Map<String, dynamic>? json) {
    if (json == null) return CustomColors();
    return CustomColors(
      primary: json['primary'] ?? '#1C1B1F',
      secondary: json['secondary'] ?? '#5C6AC4',
      accent: json['accent'] ?? '#5C6AC4',
    );
  }

  Map<String, dynamic> toJson() => {
    'primary': primary,
    'secondary': secondary,
    'accent': accent,
  };
}

class SocialLinks {
  final String? facebook;
  final String? instagram;
  final String? tiktok;

  SocialLinks({
    this.facebook,
    this.instagram,
    this.tiktok,
  });

  factory SocialLinks.fromJson(Map<String, dynamic>? json) {
    if (json == null) return SocialLinks();
    return SocialLinks(
      facebook: json['facebook'],
      instagram: json['instagram'],
      tiktok: json['tiktok'],
    );
  }

  Map<String, dynamic> toJson() => {
    'facebook': facebook,
    'instagram': instagram,
    'tiktok': tiktok,
  };
}

class StoreSettings {
  final String id;
  String storeNameAr;
  String? storeNameFr;
  String? storeDescriptionAr;
  String? storeDescriptionFr;
  String? logoUrl;
  String phone;
  String? whatsappNumber;
  String? email;
  String? address;

  // Visual Theme & Hero
  String themeName;
  String heroVariant; // 'editorial-bento' | 'cinematic-slider' | 'modern-split' | 'minimal-clean' | 'dynamic-grid'
  String? heroTitle;
  String? heroSubtitle;
  String? heroBadge;
  String? heroCtaText;
  String? heroImageUrl;
  List<BannerItem> banners;
  CustomColors customColors;

  // Shipping Configuration
  double? defaultHomeShippingCost;
  double? defaultDeskShippingCost;
  double? freeShippingThreshold;
  List<WilayaTarif> wilayasShipping;

  // Maintenance & System
  bool maintenanceMode;
  String? maintenanceMessage;
  SocialLinks socialLinks;
  String defaultLanguage;

  StoreSettings({
    this.id = 'store-settings-1',
    required this.storeNameAr,
    this.storeNameFr,
    this.storeDescriptionAr,
    this.storeDescriptionFr,
    this.logoUrl,
    required this.phone,
    this.whatsappNumber,
    this.email,
    this.address,
    this.themeName = 'midnight',
    this.heroVariant = 'editorial-bento',
    this.heroTitle,
    this.heroSubtitle,
    this.heroBadge,
    this.heroCtaText,
    this.heroImageUrl,
    this.banners = const [],
    required this.customColors,
    this.defaultHomeShippingCost = 700,
    this.defaultDeskShippingCost = 400,
    this.freeShippingThreshold = 10000,
    this.wilayasShipping = const [],
    this.maintenanceMode = false,
    this.maintenanceMessage,
    required this.socialLinks,
    this.defaultLanguage = 'ar',
  });

  factory StoreSettings.fromJson(Map<String, dynamic> json) {
    List<BannerItem> parsedBanners = [];
    if (json['banners'] != null && json['banners'] is List) {
      parsedBanners = (json['banners'] as List)
          .map((b) => BannerItem.fromJson(b as Map<String, dynamic>))
          .toList();
    }

    List<WilayaTarif> parsedWilayas = [];
    if (json['wilayas_shipping'] != null && json['wilayas_shipping'] is List) {
      parsedWilayas = (json['wilayas_shipping'] as List)
          .map((w) => WilayaTarif.fromJson(w as Map<String, dynamic>))
          .toList();
    }

    String nameAr = 'المتجر الجزائري الحديث';
    if (json['store_name'] is Map) {
      nameAr = json['store_name']['ar'] ?? nameAr;
    } else if (json['store_name'] != null) {
      nameAr = json['store_name'].toString();
    }

    String? descAr;
    if (json['store_description'] is Map) {
      descAr = json['store_description']['ar'];
    } else if (json['store_description'] != null) {
      descAr = json['store_description'].toString();
    }

    return StoreSettings(
      id: json['_id'] ?? json['id'] ?? 'store-settings-1',
      storeNameAr: nameAr,
      storeNameFr: json['store_name'] is Map ? json['store_name']['fr'] : null,
      storeDescriptionAr: descAr,
      storeDescriptionFr: json['store_description'] is Map ? json['store_description']['fr'] : null,
      logoUrl: json['logo_url'],
      phone: json['phone'] ?? '0541790205',
      whatsappNumber: json['whatsapp'] ?? json['whatsapp_number'] ?? '213541790205',
      email: json['email'] ?? 'contact@algerianstore.dz',
      address: json['address'] ?? 'الجزائر العاصمة، الجزائر',
      themeName: json['theme_name'] ?? 'midnight',
      heroVariant: json['hero_variant'] ?? 'editorial-bento',
      heroTitle: json['hero_title'] ?? 'تسوق أفضل المنتجات مع توصيل سريع لـ 69 ولاية',
      heroSubtitle: json['hero_subtitle'] ?? 'دفع آمن عند الاستلام، ضمان الجودة، وخدمة عملاء على مدار الساعة',
      heroBadge: json['hero_badge'] ?? '🔥 عروض وتخفيضات كبرى',
      heroCtaText: json['hero_cta_text'] ?? 'تسوق الآن',
      heroImageUrl: json['hero_image_url'] ?? 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?auto=format&fit=crop&w=1200&q=80',
      banners: parsedBanners,
      customColors: CustomColors.fromJson(json['custom_colors']),
      defaultHomeShippingCost: (json['default_home_shipping_cost'] ?? 700).toDouble(),
      defaultDeskShippingCost: (json['default_desk_shipping_cost'] ?? 400).toDouble(),
      freeShippingThreshold: (json['free_shipping_threshold'] ?? 10000).toDouble(),
      wilayasShipping: parsedWilayas,
      maintenanceMode: json['maintenance_mode'] ?? false,
      maintenanceMessage: json['maintenance_message'] ?? 'المتجر في وضع صيانة مؤقت. سنعود قريباً!',
      socialLinks: SocialLinks.fromJson(json['social_links'] ?? {
        'facebook': json['social_facebook'],
        'instagram': json['social_instagram'],
        'tiktok': json['social_tiktok'],
      }),
      defaultLanguage: json['default_language'] ?? 'ar',
    );
  }

  Map<String, dynamic> toJson() => {
    'store_name': storeNameAr,
    'phone': phone,
    'whatsapp': whatsappNumber,
    'email': email,
    'address': address,
    'logo_url': logoUrl,
    'theme_name': themeName,
    'hero_variant': heroVariant,
    'hero_title': heroTitle,
    'hero_subtitle': heroSubtitle,
    'hero_badge': heroBadge,
    'hero_cta_text': heroCtaText,
    'hero_image_url': heroImageUrl,
    'banners': banners.map((b) => b.toJson()).toList(),
    'custom_colors': customColors.toJson(),
    'default_home_shipping_cost': defaultHomeShippingCost,
    'default_desk_shipping_cost': defaultDeskShippingCost,
    'free_shipping_threshold': freeShippingThreshold,
    'wilayas_shipping': wilayasShipping.map((w) => w.toJson()).toList(),
    'maintenance_mode': maintenanceMode,
    'maintenance_message': maintenanceMessage,
    'social_facebook': socialLinks.facebook,
    'social_instagram': socialLinks.instagram,
    'social_tiktok': socialLinks.tiktok,
    'default_language': defaultLanguage,
  };
}
