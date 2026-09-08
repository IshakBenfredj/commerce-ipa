import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../services/notification_service.dart';
import '../../providers/realtime_notification_provider.dart';

import '../../services/background_service.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  final NotificationService _notifService = NotificationService();

  bool _ordersAlerts = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _isSendingTest = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    await _notifService.init();
    setState(() {
      _soundEnabled = _notifService.soundEnabled;
      _vibrationEnabled = _notifService.vibrationEnabled;
    });
  }

  Future<void> _sendTestNotification() async {
    setState(() => _isSendingTest = true);

    // Also trigger in-app realtime banner via provider for visual confirmation
    context.read<RealtimeNotificationProvider>().triggerManualTestOrder();

    // Trigger local Android system notification with sound and vibration
    try {
      await triggerTestLocalNotification();
    } catch (_) {}

    final success = await _notifService.sendTestNotification();

    if (mounted) {
      setState(() => _isSendingTest = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'تم إرسال الإشعار التجريبي والتنبيه الصوتي بنجاح ⚡'
              : 'تم تفعيل التنبيه التجريبي داخل التطبيق'),
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
            'الإشعارات والتنبيهات الفورية',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Realtime Status Banner ────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: realtimeNotif.isConnected
                            ? AppColors.successBg
                            : AppColors.warningBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        realtimeNotif.isConnected
                            ? LucideIcons.radio
                            : LucideIcons.wifiOff,
                        color: realtimeNotif.isConnected
                            ? AppColors.success
                            : AppColors.warning,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            realtimeNotif.isConnected
                                ? 'الخادم الفوري متصل (Socket.IO)'
                                : 'جاري الاتصال بالخادم...',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: realtimeNotif.isConnected
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'يتم استقبال الطلبيات الجديدة بشكل فوري بدون الحاجة لتحديث الصفحة.',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.textSub),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── 2. Notification Preferences ──────────────────────────────
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
                        Icon(LucideIcons.bellRing,
                            size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('خيارات التنبيه والصوت',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text)),
                      ],
                    ),
                    const Divider(height: 20, color: AppColors.divider),
                    SwitchListTile(
                      value: _ordersAlerts,
                      onChanged: (val) => setState(() => _ordersAlerts = val),
                      title: const Text('تنبيهات الطلبيات الجديدة',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                      subtitle: const Text(
                          'إظهار شريط إشعار علوي فوري عند تسجيل طلبية جديدة',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textSub)),
                      activeThumbColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(height: 12, color: AppColors.divider),
                    SwitchListTile(
                      value: _soundEnabled,
                      onChanged: (val) {
                        setState(() => _soundEnabled = val);
                        _notifService.setSoundEnabled(val);
                      },
                      title: const Text('الصوت والرنين',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                      subtitle: const Text(
                          'تشغيل نغمة تنبيه صوتية مميزة مع وصول كل طلبية',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textSub)),
                      activeThumbColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(height: 12, color: AppColors.divider),
                    SwitchListTile(
                      value: _vibrationEnabled,
                      onChanged: (val) {
                        setState(() => _vibrationEnabled = val);
                        _notifService.setVibrationEnabled(val);
                      },
                      title: const Text('الاهتزاز (Vibration)',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                      subtitle: const Text('اهتزاز الهاتف لتنبيه التاجر فورياً',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textSub)),
                      activeThumbColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── 3. Test Notification Action ──────────────────────────────
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
                        Icon(LucideIcons.zap,
                            size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('اختبار نظام الإشعارات',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text)),
                      ],
                    ),
                    const Divider(height: 20, color: AppColors.divider),
                    const Text(
                      'اضغط على الزر أدناه لتجربة وصول طلبية فورية وسماع التنبيه الصوتي ومشاهدة الشريط التفاعلي العلوي:',
                      style: TextStyle(fontSize: 12, color: AppColors.textSub),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            _isSendingTest ? null : _sendTestNotification,
                        icon: _isSendingTest
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Icon(LucideIcons.bellPlus, size: 18),
                        label: Text(
                            _isSendingTest
                                ? 'جاري الاختبار...'
                                : 'إرسال إشعار تجريبي فوري ⚡',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w800)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
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
