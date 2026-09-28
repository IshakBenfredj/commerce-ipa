import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'constants/colors.dart';
import 'providers/theme_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/products_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/realtime_notification_provider.dart';
import 'screens/main_navigation_screen.dart';

import 'services/background_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase & FCM for Background / Terminated Notifications
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await FcmService().initialize();
  } catch (e) {
    // ignore: avoid_print
    print('Failed to initialize Firebase: $e');
  }

  // 2. Initialize Background Service for Real-time Fallback
  try {
    await initializeBackgroundService();
  } catch (e) {
    // ignore: avoid_print
    print('Failed to initialize background service: $e');
  }
  runApp(const AlgerianStoreDashboardApp());
}

class AlgerianStoreDashboardApp extends StatelessWidget {
  const AlgerianStoreDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => RealtimeNotificationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Store Orders',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            locale: const Locale('ar', 'DZ'),
            supportedLocales: const [
              Locale('ar', 'DZ'),
              Locale('fr', 'FR'),
              Locale('en', 'US'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}
