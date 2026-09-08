import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/orders_provider.dart';
import '../providers/products_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/realtime_notification_provider.dart';
import '../widgets/realtime_order_banner.dart';
import 'home_screen.dart';
import 'orders_screen.dart';
import 'products_screen.dart';
import 'settings_screen.dart';
import 'order_details_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    OrdersScreen(),
    ProductsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().fetchOrders();
      context.read<ProductsProvider>().fetchProductsAndCategories();
      context.read<SettingsProvider>().fetchSettings();

      // Initialize Socket.IO real-time notification listener
      context.read<RealtimeNotificationProvider>().initialize((newOrder) {
        // Add new order to orders provider state
        context.read<OrdersProvider>().addRealtimeOrder(newOrder);
      });
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final realtimeNotif = context.watch<RealtimeNotificationProvider>();
    final ordersProvider = context.watch<OrdersProvider>();

    final pendingCount =
        ordersProvider.orders.where((o) => o.status == 'pending').length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Stack(
          children: [
            // Active Tab Body
            IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),

            // Top Realtime Notification Alert Banner
            if (realtimeNotif.isBannerVisible &&
                realtimeNotif.latestOrder != null)
              RealtimeOrderBanner(
                order: realtimeNotif.latestOrder!,
                onTap: () {
                  realtimeNotif.dismissBanner();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          OrderDetailsScreen(order: realtimeNotif.latestOrder!),
                    ),
                  );
                },
                onDismiss: () {
                  realtimeNotif.dismissBanner();
                },
              ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: const Border(
                top: BorderSide(color: AppColors.border, width: 1)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E1B4B).withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.surface,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textMuted,
            selectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
            elevation: 0,
            items: [
              const BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(LucideIcons.layoutDashboard, size: 22),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(LucideIcons.layoutDashboard,
                      size: 22, color: AppColors.primary),
                ),
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Badge(
                    isLabelVisible: pendingCount > 0,
                    label: Text(
                      '$pendingCount',
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: AppColors.warning,
                    child: const Icon(LucideIcons.shoppingBag, size: 22),
                  ),
                ),
                activeIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Badge(
                    isLabelVisible: pendingCount > 0,
                    label: Text(
                      '$pendingCount',
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: AppColors.warning,
                    child: const Icon(LucideIcons.shoppingBag,
                        size: 22, color: AppColors.primary),
                  ),
                ),
                label: 'الطلبيات',
              ),
              const BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(LucideIcons.package, size: 22),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(LucideIcons.package,
                      size: 22, color: AppColors.primary),
                ),
                label: 'المنتجات',
              ),
              const BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(LucideIcons.settings, size: 22),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(LucideIcons.settings,
                      size: 22, color: AppColors.primary),
                ),
                label: 'الإعدادات',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
