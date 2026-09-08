import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/store_settings.dart';
import '../models/dashboard_stats.dart';
import '../models/coupon.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${ApiEndpoints.adminApiKey}',
  };

  // ── Orders ─────────────────────────────────────────────────────────────
  Future<List<Order>> getOrders({String? status, String? search}) async {
    try {
      final queryParams = <String, String>{};
      if (status != null && status != 'all') queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final uri = Uri.parse(ApiEndpoints.orders).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        if (data['success'] == true && data['data'] is List) {
          return (data['data'] as List).map((o) => Order.fromJson(o)).toList();
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('ApiService.getOrders error: $e');
    }
    return [];
  }

  Future<Order?> getOrderById(String id) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.orderById}/$id');
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        if (data['success'] == true && data['data'] != null) {
          return Order.fromJson(data['data']);
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('ApiService.getOrderById error: $e');
    }
    return null;
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus, {String? notes}) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.updateOrderStatus}/$orderId/status');
      final res = await http.patch(
        uri,
        headers: _headers,
        body: jsonEncode({
          'status': newStatus,
          if (notes != null) 'note': notes,
        }),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        return data['success'] == true;
      }
    } catch (e) {
      // ignore: avoid_print
      print('ApiService.updateOrderStatus error: $e');
    }
    return false;
  }

  // ── Analytics / Dashboard ──────────────────────────────────────────────
  Future<DashboardStats?> getDashboardStats() async {
    try {
      final uri = Uri.parse(ApiEndpoints.analytics);
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        if (data['success'] == true && data['data'] != null) {
          return DashboardStats.fromJson(data['data']);
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('ApiService.getDashboardStats error: $e');
    }
    return null;
  }

  // ── Products ───────────────────────────────────────────────────────────
  Future<List<Product>> getProducts({String? categoryId, String? search}) async {
    try {
      final queryParams = <String, String>{'all': 'true'};
      if (categoryId != null && categoryId.isNotEmpty) queryParams['category'] = categoryId;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final uri = Uri.parse(ApiEndpoints.products).replace(queryParameters: queryParams);
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        if (data['success'] == true && data['data'] is List) {
          return (data['data'] as List).map((p) => Product.fromJson(p)).toList();
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('ApiService.getProducts error: $e');
    }
    return [];
  }

  Future<Product?> getProductById(String id) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.products}/$id');
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        if (data['success'] == true && data['data'] != null) {
          return Product.fromJson(data['data']);
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('ApiService.getProductById error: $e');
    }
    return null;
  }

  Future<bool> saveProduct(Product product) async {
    try {
      final payload = product.toJson();
      http.Response res;

      if (product.id.isNotEmpty && !product.id.startsWith('prod-')) {
        final uri = Uri.parse('${ApiEndpoints.products}/${product.id}');
        res = await http.put(uri, headers: _headers, body: jsonEncode(payload)).timeout(const Duration(seconds: 12));
      } else {
        final uri = Uri.parse(ApiEndpoints.products);
        res = await http.post(uri, headers: _headers, body: jsonEncode(payload)).timeout(const Duration(seconds: 12));
      }

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        return data['success'] == true;
      }
    } catch (e) {
      // ignore: avoid_print
      print('ApiService.saveProduct error: $e');
    }
    return false;
  }

  Future<bool> deleteProduct(String id) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.products}/$id');
      final res = await http.delete(uri, headers: _headers).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        return data['success'] == true;
      }
    } catch (e) {
      // ignore: avoid_print
      print('ApiService.deleteProduct error: $e');
    }
    return false;
  }

  // ── Categories ─────────────────────────────────────────────────────────
  Future<List<Category>> getCategories() async {
    try {
      final uri = Uri.parse(ApiEndpoints.categories);
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        if (data['success'] == true && data['data'] is List) {
          return (data['data'] as List).map((c) => Category.fromJson(c)).toList();
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('ApiService.getCategories error: $e');
    }
    return [];
  }

  // ── Store Settings ─────────────────────────────────────────────────────
  Future<StoreSettings?> getStoreSettings() async {
    try {
      final uri = Uri.parse(ApiEndpoints.storeSettings);
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        if (data['success'] == true && data['data'] != null) {
          return StoreSettings.fromJson(data['data']);
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('ApiService.getStoreSettings error: $e');
    }
    return null;
  }

  Future<bool> updateStoreSettings(StoreSettings settings) async {
    try {
      final uri = Uri.parse(ApiEndpoints.storeSettings);
      final payload = settings.toJson();

      final res = await http.put(
        uri,
        headers: _headers,
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        return data['success'] == true;
      }
    } catch (e) {
      // ignore: avoid_print
      print('ApiService.updateStoreSettings error: $e');
    }
    return false;
  }

  // ── Coupons ────────────────────────────────────────────────────────────
  Future<List<Coupon>> getCoupons() async {
    try {
      final uri = Uri.parse(ApiEndpoints.coupons);
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        if (data['success'] == true && data['data'] is List) {
          return (data['data'] as List).map((c) => Coupon.fromJson(c)).toList();
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('ApiService.getCoupons error: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>> createCoupon(Map<String, dynamic> couponData) async {
    try {
      final uri = Uri.parse(ApiEndpoints.coupons);
      final res = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(couponData),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(utf8.decode(res.bodyBytes));
      if (res.statusCode == 200 || res.statusCode == 201) {
        return {'success': true, 'data': Coupon.fromJson(data['data']), 'message': data['message'] ?? 'تم إنشاء الكوبون بنجاح'};
      } else {
        return {'success': false, 'error': data['error'] ?? 'فشل إنشاء الكوبون'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<bool> toggleCouponActive(String id, bool isActive) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.coupons}/$id/toggle');
      final res = await http.patch(
        uri,
        headers: _headers,
        body: jsonEncode({'is_active': isActive}),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        return data['success'] == true;
      }
    } catch (e) {
      // ignore: avoid_print
      print('ApiService.toggleCouponActive error: $e');
    }
    return false;
  }

  Future<bool> deleteCoupon(String id) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.coupons}/$id');
      final res = await http.delete(uri, headers: _headers).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        return data['success'] == true;
      }
    } catch (e) {
      // ignore: avoid_print
      print('ApiService.deleteCoupon error: $e');
    }
    return false;
  }
}
