class DashboardStats {
  final double totalSales;
  final int totalOrders;
  final int pendingCount;
  final int confirmedCount;
  final int deliveredCount;
  final int cancelledCount;
  final int lowStockCount;
  final double averageOrderValue;

  DashboardStats({
    required this.totalSales,
    required this.totalOrders,
    required this.pendingCount,
    required this.confirmedCount,
    required this.deliveredCount,
    required this.cancelledCount,
    this.lowStockCount = 0,
    required this.averageOrderValue,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalSales: (json['totalRevenue'] ?? json['totalSales'] ?? 0).toDouble(),
      totalOrders: json['totalOrders'] ?? 0,
      pendingCount: json['pendingOrders'] ?? json['pendingCount'] ?? 0,
      confirmedCount: json['confirmedOrders'] ?? json['confirmedCount'] ?? 0,
      deliveredCount: json['deliveredOrders'] ?? json['deliveredCount'] ?? 0,
      cancelledCount: json['cancelledOrders'] ?? json['cancelledCount'] ?? 0,
      lowStockCount: json['lowStockCount'] ?? 0,
      averageOrderValue: (json['averageOrderValue'] ?? 0).toDouble(),
    );
  }
}
