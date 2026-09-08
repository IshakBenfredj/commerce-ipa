import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_endpoints.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _soundKey = 'pref_notif_sound';
  static const String _vibrationKey = 'pref_notif_vibration';
  static const String _tokenKey = 'pref_push_token';

  bool soundEnabled = true;
  bool vibrationEnabled = true;
  String? pushToken;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      soundEnabled = prefs.getBool(_soundKey) ?? true;
      vibrationEnabled = prefs.getBool(_vibrationKey) ?? true;
      pushToken = prefs.getString(_tokenKey);
    } catch (e) {
      // ignore: avoid_print
      print('NotificationService init error: $e');
    }
  }

  Future<void> setSoundEnabled(bool value) async {
    soundEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, value);
  }

  Future<void> setVibrationEnabled(bool value) async {
    vibrationEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationKey, value);
  }

  Future<bool> registerPushToken(String token, {String deviceName = "Flutter Mobile Dashboard"}) async {
    try {
      pushToken = token;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);

      final uri = Uri.parse('${ApiEndpoints.baseUrl}/push/register');
      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiEndpoints.adminApiKey}',
        },
        body: jsonEncode({
          'token': token,
          'deviceName': deviceName,
          'platform': 'flutter',
        }),
      ).timeout(const Duration(seconds: 8));

      return res.statusCode == 200;
    } catch (e) {
      // ignore: avoid_print
      print('registerPushToken error: $e');
      return false;
    }
  }

  Future<bool> sendTestNotification() async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}/push/test');
      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiEndpoints.adminApiKey}',
        },
        body: jsonEncode({
          'title': '🔔 إشعار تجريبي ناجح!',
          'body': 'نظام الإشعارات الفورية والتنبيهات الصوتية في تطبيق فلاتر يعمل بكفاءة 100%.',
        }),
      ).timeout(const Duration(seconds: 8));

      return res.statusCode == 200;
    } catch (e) {
      // ignore: avoid_print
      print('sendTestNotification error: $e');
      return false;
    }
  }
}
