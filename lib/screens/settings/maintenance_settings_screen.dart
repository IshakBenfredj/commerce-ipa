import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/settings_provider.dart';

class MaintenanceSettingsScreen extends StatefulWidget {
  const MaintenanceSettingsScreen({super.key});

  @override
  State<MaintenanceSettingsScreen> createState() =>
      _MaintenanceSettingsScreenState();
}

class _MaintenanceSettingsScreenState extends State<MaintenanceSettingsScreen> {
  late bool _maintenanceMode;
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsProvider>().settings;
    _maintenanceMode = s?.maintenanceMode ?? false;
    _messageController = TextEditingController(
      text: s?.maintenanceMessage ?? 'المتجر في وضع صيانة مؤقت. سنعود قريباً!',
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final provider = context.read<SettingsProvider>();
    provider.updateSettings((s) {
      s.maintenanceMode = _maintenanceMode;
      s.maintenanceMessage = _messageController.text.trim();
    });

    final success = await provider.saveSettings();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(success ? 'تم تحديث حالة وضع الصيانة بنجاح' : 'تعذر الحفظ'),
          backgroundColor: success ? AppColors.success : AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<SettingsProvider>().isSaving;

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
            'وضع الصيانة والتوقف المؤقت',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.text),
          ),
          centerTitle: true,
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: ElevatedButton.icon(
            onPressed: isSaving ? null : _handleSave,
            icon: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Icon(LucideIcons.save, size: 18),
            label: Text(isSaving ? 'جاري الحفظ...' : 'حفظ إعدادات الصيانة',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _maintenanceMode ? AppColors.danger : AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Warning / Info Box ───────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _maintenanceMode
                      ? AppColors.dangerBg
                      : AppColors.warningBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _maintenanceMode
                        ? AppColors.danger.withValues(alpha: 0.3)
                        : AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _maintenanceMode
                          ? LucideIcons.alertOctagon
                          : LucideIcons.info,
                      color: _maintenanceMode
                          ? AppColors.danger
                          : AppColors.warning,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _maintenanceMode
                                ? '⚠️ المتجر في وضع التوقف والصيانة'
                                : 'تنبيه حول وضع الصيانة',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _maintenanceMode
                                  ? AppColors.danger
                                  : AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _maintenanceMode
                                ? 'الزبائن لا يمكنهم تصفح المنتجات أو تقديم طلبات حالياً. ستظهر لهم رسالة الصيانة.'
                                : 'عند تفعيل هذا الخيار، سيتم حجب واجهة المتجر عن الزوار مؤقتاً لعرض رسالة مخصصة.',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textSub),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Maintenance Switch & Message ─────────────────────────────
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
                    SwitchListTile(
                      value: _maintenanceMode,
                      onChanged: (val) =>
                          setState(() => _maintenanceMode = val),
                      title: const Text('تفعيل وضع الصيانة المؤقت',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800)),
                      subtitle: const Text('إيقاف استقبال طلبات الشراء مؤقتاً',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textSub)),
                      activeThumbColor: AppColors.danger,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(height: 20, color: AppColors.divider),
                    const Text(
                      'رسالة الصيانة المعروضة للزبائن',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _messageController,
                      maxLines: 3,
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(
                        hintText:
                            'أدخل الرسالة التي ستظهر للمستخدمين عند زيارة المتجر...',
                        hintStyle: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.border)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 1.5)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
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
