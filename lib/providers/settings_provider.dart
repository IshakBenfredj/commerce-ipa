import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/store_settings.dart';
import '../models/wilaya_tarif.dart';
import '../services/api_service.dart';

class SettingsProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  StoreSettings? _settings;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  StoreSettings? get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<void> fetchSettings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _api.getStoreSettings();
      if (fetched != null) {
        _settings = fetched;

        // If wilayas_shipping is empty, load defaults from assets/data/wilayas_tarifs.json
        if (_settings!.wilayasShipping.isEmpty) {
          final defaultWilayas = await _loadDefaultWilayasFromAsset();
          _settings!.wilayasShipping = defaultWilayas;
        }
      } else {
        // Fallback default
        _settings = StoreSettings(
          storeNameAr: 'المتجر الجزائري الحديث',
          phone: '0541790205',
          customColors: CustomColors(),
          socialLinks: SocialLinks(),
          wilayasShipping: await _loadDefaultWilayasFromAsset(),
        );
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<WilayaTarif>> _loadDefaultWilayasFromAsset() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/wilayas_tarifs.json');
      final data = jsonDecode(jsonString);
      if (data['wilayas'] is List) {
        return (data['wilayas'] as List).map((w) => WilayaTarif.fromJson(w)).toList();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Failed to load assets/data/wilayas_tarifs.json: $e');
    }
    return [];
  }

  Future<bool> saveSettings() async {
    if (_settings == null) return false;
    _isSaving = true;
    notifyListeners();

    try {
      final success = await _api.updateStoreSettings(_settings!);
      _isSaving = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isSaving = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void updateSettings(void Function(StoreSettings) callback) {
    if (_settings != null) {
      callback(_settings!);
      notifyListeners();
    }
  }

  // ── Wilayas Utilities ──────────────────────────────────────────────────
  Future<void> resetWilayasToDefault() async {
    if (_settings == null) return;
    final defaults = await _loadDefaultWilayasFromAsset();
    _settings!.wilayasShipping = defaults;
    notifyListeners();
  }

  bool importWilayasFromJson(String jsonContent) {
    if (_settings == null) return false;
    try {
      final decoded = jsonDecode(jsonContent);
      List<dynamic> list;
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map && decoded['wilayas'] is List) {
        list = decoded['wilayas'];
      } else {
        return false;
      }

      final parsed = list.map((item) => WilayaTarif.fromJson(item as Map<String, dynamic>)).toList();
      if (parsed.isNotEmpty) {
        _settings!.wilayasShipping = parsed;
        notifyListeners();
        return true;
      }
    } catch (e) {
      // ignore: avoid_print
      print('importWilayasFromJson error: $e');
    }
    return false;
  }
}
