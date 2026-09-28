import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_service.dart';

const String fcmOrdersChannelId = 'app_dashf_orders';

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

/// Top-level background message handler for FCM
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}

  // ignore: avoid_print
  print('🔔 [FCM Background Message] Received: ${message.messageId}');
  // If the message has a data payload or custom formatting, we display it
  _showLocalNotification(message);
}

/// Helper function to show heads-up notifications
Future<void> _showLocalNotification(RemoteMessage message) async {
  try {
    final notification = message.notification;
    final data = message.data;

    String title = notification?.title ?? '';
    String body = notification?.body ?? '';

    if (title.isEmpty && data.containsKey('orderNumber')) {
      title = '🛍️ طلبية جديدة #${data['orderNumber']}';
    } else if (title.isEmpty) {
      title = '🛍️ تنبيه جديد من المتجر';
    }

    if (body.isEmpty && data.containsKey('customerName')) {
      final customer = data['customerName'] ?? 'زبون';
      final wilaya = data['wilaya'] ?? '';
      final total = data['totalAmount'] ?? '';
      body = 'طلب جديد من $customer ($wilaya) بمبلغ $total دج';
    } else if (body.isEmpty) {
      body = 'تم تسجيل طلبية جديدة في لوحة التحكم.';
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      fcmOrdersChannelId,
      'تنبيهات الطلبيات الجديدة',
      channelDescription: 'إشعار فوري بصوت واهتزاز عالي عند تسجيل أي طلبية جديدة من المتجر',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.call,
      styleInformation: BigTextStyleInformation(''),
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final int notifId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _localNotifications.show(
      id: notifId,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: jsonEncode(data),
    );
  } catch (e) {
    // ignore: avoid_print
    print('Error showing FCM local notification: $e');
  }
}

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  bool _isInitialized = false;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  Future<void> initialize({Function(Map<String, dynamic>)? onOrderTapped}) async {
    if (_isInitialized) return;
    _isInitialized = true;

    // 1. Initialize Flutter Local Notifications
    const AndroidInitializationSettings initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final data = jsonDecode(response.payload!);
            if (onOrderTapped != null && data is Map<String, dynamic>) {
              onOrderTapped(data);
            }
          } catch (_) {}
        }
      },
    );

    // 2. Create Android High Priority Notification Channel
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      const AndroidNotificationChannel ordersChannel = AndroidNotificationChannel(
        fcmOrdersChannelId,
        'تنبيهات الطلبيات الجديدة',
        description: 'إشعار فوري بصوت واهتزاز عالي عند تسجيل أي طلبية جديدة من المتجر',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );
      await androidPlugin.createNotificationChannel(ordersChannel);
    }

    // 3. Request Notification Permissions (Android 13+ & iOS)
    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );

      // ignore: avoid_print
      print('🔔 [FCM] User notification permission: ${settings.authorizationStatus}');
    } catch (e) {
      // ignore: avoid_print
      print('Error requesting FCM permissions: $e');
    }

    // 4. Set Foreground presentation options
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 5. Get and register device FCM token
    await _retrieveAndRegisterToken();

    // 6. Listen to Token Refresh
    _fcm.onTokenRefresh.listen((newToken) async {
      // ignore: avoid_print
      print('🔄 [FCM] Token refreshed: ${newToken.substring(0, 15)}...');
      _fcmToken = newToken;
      await _registerTokenWithServer(newToken);
    });

    // 7. Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // ignore: avoid_print
      print('📩 [FCM Foreground Message] Received: ${message.messageId}');
      _showLocalNotification(message);
    });

    // 8. Notification opened from Background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // ignore: avoid_print
      print('📲 [FCM App Opened From Notification]: ${message.data}');
      if (onOrderTapped != null) {
        onOrderTapped(message.data);
      }
    });

    // 9. Notification opened from Terminated state
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      // ignore: avoid_print
      print('🚀 [FCM App Launched From Terminated Notification]: ${initialMessage.data}');
      if (onOrderTapped != null) {
        onOrderTapped(initialMessage.data);
      }
    }
  }

  Future<void> _retrieveAndRegisterToken() async {
    try {
      String? token;
      if (kIsWeb) {
        token = null;
      } else if (Platform.isAndroid || Platform.isIOS) {
        token = await _fcm.getToken();
      }

      if (token != null) {
        _fcmToken = token;
        // ignore: avoid_print
        print('🔑 [FCM Token] Got device token: ${token.substring(0, 20)}...');
        await _registerTokenWithServer(token);
      } else {
        // ignore: avoid_print
        print('⚠️ [FCM Token] Token returned null');
      }
    } catch (e) {
      // ignore: avoid_print
      print('❌ [FCM Token Error]: $e');
    }
  }

  Future<void> _registerTokenWithServer(String token) async {
    try {
      final success = await NotificationService().registerPushToken(
        token,
        deviceName: 'Android Device (FCM)',
      );
      // ignore: avoid_print
      print(success
          ? '✅ [FCM] Token registered successfully on backend server'
          : '⚠️ [FCM] Failed to register token on backend server');
    } catch (e) {
      // ignore: avoid_print
      print('❌ [FCM Registration Error]: $e');
    }
  }
}
