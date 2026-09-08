import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class OrdersProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedStatus = 'all';
  String _searchQuery = '';

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedStatus => _selectedStatus;
  String get searchQuery => _searchQuery;

  // Filtered orders getter
  List<Order> get filteredOrders {
    return _orders.where((o) {
      final matchesStatus = _selectedStatus == 'all' || o.status.toLowerCase() == _selectedStatus.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          o.orderNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          o.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          o.customerPhone.contains(_searchQuery) ||
          o.shippingWilaya.contains(_searchQuery);
      return matchesStatus && matchesSearch;
    }).toList();
  }

  Future<void> fetchOrders({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final fetched = await _api.getOrders();
      _orders = fetched;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilterStatus(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void addRealtimeOrder(Order newOrder) {
    // Check if already present
    final index = _orders.indexWhere((o) => o.id == newOrder.id || o.orderNumber == newOrder.orderNumber);
    if (index >= 0) {
      _orders[index] = newOrder;
    } else {
      _orders.insert(0, newOrder);
    }
    notifyListeners();
  }

  Future<bool> updateStatus(String orderId, String newStatus, {String? notes}) async {
    final success = await _api.updateOrderStatus(orderId, newStatus, notes: notes);
    if (success) {
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index >= 0) {
        _orders[index].status = newStatus;
        notifyListeners();
      }
    }
    return success;
  }
}
