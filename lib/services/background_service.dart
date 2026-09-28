import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../constants/api_endpoints.dart';

const String foregroundChannelId = 'app_dashf_foreground';
const String ordersChannelId = 'app_dashf_orders';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  // 1. Android Notification Channels
  const AndroidNotificationChannel foregroundChannel = AndroidNotificationChannel(
    foregroundChannelId,
    'خدمة استلام الطلبيات في الخلفية',
    description: 'تحافظ على اتصال التطبيق لاستقبال الطلبيات أثناء قفل الهاتف',
    importance: Importance.low,
  );

  const AndroidNotificationChannel ordersChannel = AndroidNotificationChannel(
    ordersChannelId,
    'تنبيهات الطلبيات الجديدة',
    description: 'إشعار فوري بصوت واهتزاز عند تسجيل طلبية جديدة من المتجر',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    vibrationPattern: null,
  );

  // 2. Initialize Local Notifications Plugin
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
  );

  final androidNotificationPlugin = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  if (androidNotificationPlugin != null) {
    await androidNotificationPlugin.createNotificationChannel(foregroundChannel);
    await androidNotificationPlugin.createNotificationChannel(ordersChannel);
    // Request POST_NOTIFICATIONS permission on Android 13+
    await androidNotificationPlugin.requestNotificationsPermission();
  }

  // 3. Configure Background Service (Run silently without persistent connection notifications)
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onBackgroundServiceStart,
      autoStart: true,
      isForegroundMode: false,
      notificationChannelId: foregroundChannelId,
      initialNotificationTitle: '',
      initialNotificationContent: '',
      foregroundServiceNotificationId: 999,
      foregroundServiceTypes: [AndroidForegroundType.dataSync],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onBackgroundServiceStart,
      onBackground: onIosBackground,
    ),
  );

  // Cancel any lingering foreground notification
  try {
    await flutterLocalNotificationsPlugin.cancel(id: 999);
  } catch (_) {}
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
void onBackgroundServiceStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin bgNotifications =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await bgNotifications.initialize(settings: initializationSettings);

  IO.Socket? bgSocket;

  void connectBgSocket() {
    try {
      if (bgSocket != null && bgSocket!.connected) return;

      bgSocket = IO.io(
        ApiEndpoints.socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(2000)
            .build(),
      );

      bgSocket!.onConnect((_) {
        // ignore: avoid_print
        print('⚡ [BG Service] Connected to Socket.IO on: ${ApiEndpoints.socketUrl}');
      });

      bgSocket!.onDisconnect((_) {
        // ignore: avoid_print
        print('❌ [BG Service] Disconnected from Socket.IO');
      });

      bgSocket!.on('new_order', (data) {
        // ignore: avoid_print
        print('🔔 [BG Service] new_order received: $data');
        _showOrderHeadsUpNotification(bgNotifications, data);
        service.invoke('bg_order_received', data is Map ? Map<String, dynamic>.from(data) : {});
      });

      bgSocket!.on('order:created', (data) {
        _showOrderHeadsUpNotification(bgNotifications, data);
        service.invoke('bg_order_received', data is Map ? Map<String, dynamic>.from(data) : {});
      });
    } catch (e) {
      // ignore: avoid_print
      print('BG Service socket error: $e');
    }
  }

  connectBgSocket();

  service.on('stop_service').listen((event) {
    bgSocket?.disconnect();
    service.stopSelf();
  });
}

Future<void> _showOrderHeadsUpNotification(
  FlutterLocalNotificationsPlugin notificationsPlugin,
  dynamic data,
) async {
  if (data == null) return;
  try {
    Map<String, dynamic> jsonMap;
    if (data is Map<String, dynamic>) {
      jsonMap = data;
    } else if (data is Map) {
      jsonMap = Map<String, dynamic>.from(data);
    } else {
      return;
    }

    if (jsonMap.containsKey('order') && jsonMap['order'] is Map) {
      jsonMap = Map<String, dynamic>.from(jsonMap['order'] as Map);
    }

    final String orderNumber = jsonMap['order_number'] ?? 'جديدة';
    final String customerName = jsonMap['customer_name'] ?? 'زبون';
    final dynamic totalAmount = jsonMap['total_amount'] ?? 0;
    final String wilaya = jsonMap['wilaya_name'] ?? jsonMap['shipping_wilaya'] ?? '';

    final int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      ordersChannelId,
      'تنبيهات الطلبيات الجديدة',
      channelDescription: 'إشعار فوري بصوت واهتزاز عند تسجيل طلبية جديدة من المتجر',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.call,
      styleInformation: BigTextStyleInformation(''),
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    final String bodyText =
        'طلب جديد من $customerName ($wilaya) بمبلغ $totalAmount دج';

    await notificationsPlugin.show(
      id: notificationId,
      title: '🛍️ طلبية جديدة #$orderNumber',
      body: bodyText,
      notificationDetails: notificationDetails,
    );
  } catch (e) {
    // ignore: avoid_print
    print('Error displaying heads up notification: $e');
  }
}

/// Helper to test notifications immediately from UI
Future<void> triggerTestLocalNotification() async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    ordersChannelId,
    'تنبيهات الطلبيات الجديدة',
    channelDescription: 'إشعار فوري بصوت واهتزاز عند تسجيل طلبية جديدة من المتجر',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
  );
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    id: 101,
    title: '🛍️ طلبية تجريبية #DZ-9999',
    body: 'طلب تجريبي من محمد الأمين (الجزائر العاصمة) بمبلغ 6,500 دج',
    notificationDetails: notificationDetails,
  );
}
