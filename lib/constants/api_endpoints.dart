class ApiEndpoints {
  // Default server URLs
  // 192.168.8.200 is the local Wi-Fi IP of the host machine
  static const String defaultLocalIp = "192.168.8.200";
  static const String defaultPort = "5000";

  static String baseUrl = "http://192.168.8.200:5000/api";
  static String socketUrl = "http://192.168.8.200:5000";

  // Admin secret key
  static const String adminApiKey = "admin_secret_key_0541790205";

  // Endpoints
  static String get orders => "$baseUrl/orders";
  static String get orderById => "$baseUrl/orders";
  static String get updateOrderStatus => "$baseUrl/orders";
  static String get analytics => "$baseUrl/analytics";
  static String get products => "$baseUrl/products";
  static String get categories => "$baseUrl/categories/all";
  static String get categoryCrud => "$baseUrl/categories";
  static String get storeSettings => "$baseUrl/store/settings";
  static String get upload => "$baseUrl/upload";
  static String get coupons => "$baseUrl/coupons";

  static void setBaseHost(String host, {String port = "5000"}) {
    String cleanHost = host.replaceAll(RegExp(r'^https?:\/\/'), '').replaceAll(RegExp(r'\/.*$'), '');
    if (cleanHost.contains(':')) {
      baseUrl = "http://$cleanHost/api";
      socketUrl = "http://$cleanHost";
    } else {
      baseUrl = "http://$cleanHost:$port/api";
      socketUrl = "http://$cleanHost:$port";
    }
  }
}
