class ApiEndpoints {
  // Default server URLs
  static const String defaultLocalIp = "exommerceakmed.onrender.com";
  static const String defaultPort = "";

  static String baseUrl = "https://exommerceakmed.onrender.com/api";
  static String socketUrl = "https://exommerceakmed.onrender.com";

  // Admin secret key
  static const String adminApiKey = "AUKV1eVO3A80KgJ5";

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

  static void setBaseHost(String host, {String port = ""}) {
    String cleanHost = host
        .replaceAll(RegExp(r'^https?:\/\/'), '')
        .replaceAll(RegExp(r'\/.*$'), '');
    if (cleanHost.contains('.onrender.com') || cleanHost.contains('.')) {
      baseUrl = "https://$cleanHost/api";
      socketUrl = "https://$cleanHost";
    } else if (cleanHost.contains(':')) {
      baseUrl = "http://$cleanHost/api";
      socketUrl = "http://$cleanHost";
    } else if (port.isNotEmpty) {
      baseUrl = "http://$cleanHost:$port/api";
      socketUrl = "http://$cleanHost:$port";
    } else {
      baseUrl = "https://$cleanHost/api";
      socketUrl = "https://$cleanHost";
    }
  }
}
