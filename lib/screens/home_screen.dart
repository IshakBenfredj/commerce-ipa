import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:url_launcher/url_launcher.dart';
import '../constants/colors.dart';
import '../constants/api_endpoints.dart';
import '../providers/orders_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/realtime_notification_provider.dart';
import '../widgets/kpi_card.dart';
import '../widgets/order_row_card.dart';
import 'order_details_screen.dart';
import 'product_form_screen.dart';
import 'settings/shipping_settings_screen.dart';
import 'settings/hero_settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openLiveStore(BuildContext context) async {
    final uri = Uri.parse('http://${ApiEndpoints.defaultLocalIp}:3000');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح رابط المتجر')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.watch<OrdersProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final realtimeNotif = context.watch<RealtimeNotificationProvider>();

    final currencyFormatter = NumberFormat('#,###');

    // Calculate metrics: Only count confirmed / active sales (strictly exclude cancelled and returned)
    final orders = ordersProvider.orders;
    final confirmedOrders = orders.where((o) =>
        o.status == 'confirmed' ||
        o.status == 'shipped' ||
        o.status == 'delivered' ||
        o.status == 'processing');
    final totalSales = confirmedOrders.fold<double>(0, (sum, o) => sum + o.totalAmount);
    final pendingCount = orders.where((o) => o.status == 'pending').length;
    final deliveredCount = orders.where((o) => o.status == 'delivered').length;
    final recentOrders = orders.take(5).toList();

    final storeName = settingsProvider.settings?.storeNameAr ?? 'المتجر الجزائري الحديث';

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ordersProvider.fetchOrders(showLoading: false),
            settingsProvider.fetchSettings(),
          ]);
        },
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.rtl,
            children: [
              // ── 1. Top Header ───────────────────────────────────────────
              Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        storeName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'لوحة إدارة المتجر والطلبيات',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMutedOf(context),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Test realtime alert trigger button
                      IconButton(
                        onPressed: () {
                          realtimeNotif.triggerManualTestOrder();
                        },
                        icon: const Icon(LucideIcons.bell, size: 20, color: AppColors.primary),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primaryBg,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        tooltip: 'إشعار تجريبي',
                      ),
                      const SizedBox(width: 8),
                      // Store Link
                      IconButton(
                        onPressed: () => _openLiveStore(context),
                        icon: const Icon(LucideIcons.externalLink, size: 20, color: AppColors.primary),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primaryBg,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        tooltip: 'معاينة المتجر',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── 2. KPI Metrics Grid ─────────────────────────────────────
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.25,
                children: [
                  KpiCard(
                    title: 'إجمالي المبيعات',
                    value: '${currencyFormatter.format(totalSales)} د.ج',
                    icon: LucideIcons.trendingUp,
                    iconColor: AppColors.primary,
                    iconBgColor: AppColors.primaryBg,
                    badgeText: 'مؤكدة',
                    badgeColor: AppColors.success,
                  ),
                  KpiCard(
                    title: 'إجمالي الطلبيات',
                    value: '${orders.length}',
                    icon: LucideIcons.shoppingBag,
                    iconColor: AppColors.purple,
                    iconBgColor: AppColors.purpleBg,
                  ),
                  KpiCard(
                    title: 'قيد الانتظار',
                    value: '$pendingCount',
                    icon: LucideIcons.clock,
                    iconColor: AppColors.warning,
                    iconBgColor: AppColors.warningBg,
                    badgeText: pendingCount > 0 ? 'مستعجل' : null,
                    badgeColor: AppColors.warning,
                  ),
                  KpiCard(
                    title: 'تم التوصيل',
                    value: '$deliveredCount',
                    icon: LucideIcons.checkCircle2,
                    iconColor: AppColors.success,
                    iconBgColor: AppColors.successBg,
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // ── 3. Quick Actions ────────────────────────────────────────
              const Text(
                'إجراءات سريعة',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 10),
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(
                    child: _QuickActionButton(
                      title: 'إضافة منتج',
                      icon: LucideIcons.plusCircle,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ProductFormScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickActionButton(
                      title: 'إعدادات الشحن',
                      icon: LucideIcons.truck,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ShippingSettingsScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickActionButton(
                      title: 'قالب الهيرو',
                      icon: LucideIcons.layers,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const HeroSettingsScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── 4. Recent Orders Section ────────────────────────────────
              Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'أحدث الطلبيات',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  if (orders.isNotEmpty)
                    Text(
                      '${orders.length} طلبية',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSub,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (ordersProvider.isLoading && orders.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (recentOrders.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Column(
                    children: [
                      Icon(LucideIcons.inbox, size: 40, color: AppColors.textMuted),
                      SizedBox(height: 10),
                      Text(
                        'لا توجد طلبيات بعد',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'ستظهر الطلبيات الجديدة هنا فور تسجيلها في متجرك.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSub),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentOrders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final order = recentOrders[index];
                    return OrderRowCard(
                      order: order,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => OrderDetailsScreen(order: order),
                          ),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
