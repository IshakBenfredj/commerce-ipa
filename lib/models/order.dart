class OrderItem {
  final String id;
  final String orderId;
  final String productTitle;
  final String? variantTitle;
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  final String? imageUrl;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productTitle,
    this.variantTitle,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json, {String orderId = ''}) {
    double price = (json['price'] ?? json['unit_price'] ?? 0).toDouble();
    int qty = (json['quantity'] ?? 1) is int ? json['quantity'] ?? 1 : int.tryParse(json['quantity'].toString()) ?? 1;
    return OrderItem(
      id: json['_id'] ?? json['id'] ?? 'item-${DateTime.now().millisecondsSinceEpoch}',
      orderId: orderId,
      productTitle: json['product_name'] ?? json['product_title'] ?? json['name'] ?? 'منتج',
      variantTitle: json['selected_color'] ?? json['selected_size'] ?? json['variant_title'],
      unitPrice: price,
      quantity: qty,
      totalPrice: (json['total_price'] ?? (price * qty)).toDouble(),
      imageUrl: json['image_url'] ?? json['image'],
    );
  }

  Map<String, dynamic> toJson() => {
    'product_name': productTitle,
    'selected_color': variantTitle,
    'price': unitPrice,
    'quantity': quantity,
    'total_price': totalPrice,
    'image_url': imageUrl,
  };
}

class Order {
  final String id;
  final String orderNumber;
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final String shippingWilaya;
  final String shippingCity;
  final String shippingAddress;
  final String deliveryType; // 'home' | 'desk'
  final double shippingCost;
  final double subtotal;
  final double discountAmount;
  final double totalAmount;
  final String? couponCode;
  final String paymentMethod;
  final String paymentStatus;
  String status; // 'pending' | 'confirmed' | 'shipped' | 'delivered' | 'cancelled' | 'returned'
  final String? customerNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
    required this.shippingWilaya,
    required this.shippingCity,
    required this.shippingAddress,
    required this.deliveryType,
    required this.shippingCost,
    required this.subtotal,
    required this.discountAmount,
    required this.totalAmount,
    this.couponCode,
    this.paymentMethod = 'cod',
    this.paymentStatus = 'pending',
    required this.status,
    this.customerNotes,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    String ordId = json['_id'] ?? json['id'] ?? '';
    List<OrderItem> parsedItems = [];
    if (json['items'] != null && json['items'] is List) {
      parsedItems = (json['items'] as List)
          .map((i) => OrderItem.fromJson(i as Map<String, dynamic>, orderId: ordId))
          .toList();
    }

    return Order(
      id: ordId,
      orderNumber: json['order_number'] ?? 'DZ-${ordId.length > 4 ? ordId.substring(ordId.length - 4) : ordId}',
      customerName: json['customer_name'] ?? 'زبون',
      customerPhone: json['customer_phone'] ?? '',
      customerEmail: json['customer_phone2'] ?? json['customer_email'],
      shippingWilaya: json['wilaya_name'] ?? json['shipping_wilaya'] ?? 'الجزائر',
      shippingCity: json['commune'] ?? json['shipping_city'] ?? '',
      shippingAddress: json['address'] ?? json['shipping_address'] ?? '',
      deliveryType: json['shipping_type'] ?? json['delivery_type'] ?? 'home',
      shippingCost: (json['shipping_cost'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      discountAmount: (json['discount'] ?? json['discount_amount'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      couponCode: json['coupon_code'],
      paymentMethod: json['payment_method'] ?? 'cod',
      paymentStatus: json['payment_status'] ?? 'pending',
      status: json['status'] ?? 'pending',
      customerNotes: json['notes'] ?? json['customer_notes'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : (json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : (json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now() : DateTime.now()),
      items: parsedItems,
    );
  }
}
