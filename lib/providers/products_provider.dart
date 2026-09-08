import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/api_service.dart';

class ProductsProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List<Product> _products = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedCategory;
  String _searchQuery = '';

  List<Product> get products => _products;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<Product> get filteredProducts {
    return _products.where((p) {
      final matchesCategory = _selectedCategory == null ||
          _selectedCategory == 'all' ||
          p.categoryId == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          p.titleAr.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p.sku != null && p.sku!.toLowerCase().contains(_searchQuery.toLowerCase())) ||
          (p.titleFr != null && p.titleFr!.toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> fetchProductsAndCategories({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final resList = await Future.wait([
        _api.getProducts(),
        _api.getCategories(),
      ]);
      _products = resList[0] as List<Product>;
      _categories = resList[1] as List<Category>;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedCategory(String? categoryId) {
    _selectedCategory = categoryId;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<bool> saveProduct(Product product) async {
    final success = await _api.saveProduct(product);
    if (success) {
      await fetchProductsAndCategories(showLoading: false);
    }
    return success;
  }

  Future<bool> deleteProduct(String id) async {
    final success = await _api.deleteProduct(id);
    if (success) {
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
    }
    return success;
  }
}
