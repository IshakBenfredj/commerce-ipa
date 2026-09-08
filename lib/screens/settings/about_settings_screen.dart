import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/api_endpoints.dart';
import '../../providers/realtime_notification_provider.dart';
import '../../providers/orders_provider.dart';

class AboutSettingsScreen extends StatefulWidget {
  const AboutSettingsScreen({super.key});

  @override
  State<AboutSettingsScreen> createState() => _AboutSettingsScreenState();
}

class _AboutSettingsScreenState extends State<AboutSettingsScreen> {
  late TextEditingController _hostController;

  @override
  void initState() {
    super.initState();
    _hostController = TextEditingController(text: ApiEndpoints.baseUrl);
  }

  @override
  void dispose() {
    _hostController.dispose();
    super.dispose();
  }

  void _updateHost() {
    final newUrl = _hostController.text.trim();
    if (newUrl.isNotEmpty) {
      ApiEndpoints.baseUrl = newUrl;
      ApiEndpoints.socketUrl = newUrl.replaceAll(RegExp(r'/api$'), '');
      context.read<OrdersProvider>().fetchOrders();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث عنوان الخادم إلى: ${ApiEndpoints.baseUrl}'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final realtimeNotif = context.watch<RealtimeNotificationProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.chevronRight, color: AppColors.text),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'حول التطبيق ولوحة التحكم',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.text),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ── 1. App Logo & Version ────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            width: 2),
                      ),
                      child: const Center(
                        child: Icon(LucideIcons.store,
                            size: 36, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'لوحة تحكم التاجر الذكية (Flutter)',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'الإصدار 1.0.0 (Build 1) • نظام فلاتر المتكامل',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSub,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: realtimeNotif.isConnected
                            ? AppColors.successBg
                            : AppColors.warningBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        realtimeNotif.isConnected
                            ? 'متصل بالخادم الفوري ⚡'
                            : 'غير متصل بالخادم',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: realtimeNotif.isConnected
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── 2. Network & Server Configuration ────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(LucideIcons.network,
                            size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('عنوان خادم البيانات (API Host)',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text)),
                      ],
                    ),
                    const Divider(height: 20, color: AppColors.divider),
                    TextField(
                      controller: _hostController,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        labelText: 'رابط الخادم API URL',
                        hintText: 'http://192.168.8.200:5000/api',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _updateHost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('تحديث رابط الخادم وإعادة الاتصال',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
