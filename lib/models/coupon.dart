class Coupon {
  final String id;
  final String code;
  final String discountType; // 'percentage' or 'fixed'
  final double discountValue;
  final double minOrderAmount;
  final double? maxDiscountAmount;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? usageLimit;
  final int timesUsed;
  final bool isActive;
  final DateTime? createdAt;

  Coupon({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.minOrderAmount = 0,
    this.maxDiscountAmount,
    this.startDate,
    this.endDate,
    this.usageLimit,
    this.timesUsed = 0,
    this.isActive = true,
    this.createdAt,
  });

  bool get isExpired {
    if (endDate == null) return false;
    return endDate!.isBefore(DateTime.now());
  }

  bool get isPercentage => discountType == 'percentage';

  String get formattedDiscount {
    if (isPercentage) {
      return '${discountValue.toStringAsFixed(discountValue.truncateToDouble() == discountValue ? 0 : 1)}%';
    } else {
      return '${discountValue.toStringAsFixed(0)} دج';
    }
  }

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['_id'] ?? json['id'] ?? '',
      code: json['code'] ?? '',
      discountType: json['discount_type'] ?? 'percentage',
      discountValue: (json['discount_value'] as num?)?.toDouble() ?? 0.0,
      minOrderAmount: (json['min_order_amount'] as num?)?.toDouble() ?? 0.0,
      maxDiscountAmount: (json['max_discount_amount'] as num?)?.toDouble(),
      startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date'].toString()) : null,
      endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date'].toString()) : null,
      usageLimit: (json['usage_limit'] as num?)?.toInt(),
      timesUsed: (json['times_used'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'discount_type': discountType,
      'discount_value': discountValue,
      'min_order_amount': minOrderAmount,
      if (maxDiscountAmount != null) 'max_discount_amount': maxDiscountAmount,
      if (startDate != null) 'start_date': startDate!.toIso8601String(),
      if (endDate != null) 'end_date': endDate!.toIso8601String(),
      if (usageLimit != null) 'usage_limit': usageLimit,
      'is_active': isActive,
    };
  }

  Coupon copyWith({
    String? id,
    String? code,
    String? discountType,
    double? discountValue,
    double? minOrderAmount,
    double? maxDiscountAmount,
    DateTime? startDate,
    DateTime? endDate,
    int? usageLimit,
    int? timesUsed,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Coupon(
      id: id ?? this.id,
      code: code ?? this.code,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      usageLimit: usageLimit ?? this.usageLimit,
      timesUsed: timesUsed ?? this.timesUsed,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
