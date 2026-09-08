import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_menu_card.dart';
import 'settings/hero_settings_screen.dart';
import 'settings/appearance_settings_screen.dart';
import 'settings/identity_settings_screen.dart';
import 'settings/contact_settings_screen.dart';
import 'settings/shipping_settings_screen.dart';
import 'settings/notifications_settings_screen.dart';
import 'settings/maintenance_settings_screen.dart';
import 'settings/about_settings_screen.dart';
import 'settings/coupons_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('تسجيل الخروج',
              style: TextStyle(fontWeight: FontWeight.w800)),
          content: const Text(
              'هل أنت متأكد من رغبتك في تسجيل الخروج من لوحة تحكم المتجر؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء',
                  style: TextStyle(color: AppColors.textSub)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('تم تسجيل الخروج بنجاح'),
                      backgroundColor: AppColors.primary),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('تسجيل الخروج'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final settings = settingsProvider.settings;

    final storeName = settings?.storeNameAr ?? 'المتجر الجزائري الحديث';
    final storePhone = settings?.phone ?? '0541790205';
    final storeLogo = settings?.logoUrl;
    final isMaintenance = settings?.maintenanceMode ?? false;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => settingsProvider.fetchSettings(),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              // ── 1. Header & Store Avatar Profile ────────────────────────
              Column(
                children: [
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'إعدادات المتجر',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Avatar with active green dot
                  Stack(
                    children: [
                      Container(
                        width: 86,
                        height: 86,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFFE0E3F5), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: storeLogo != null && storeLogo.isNotEmpty
                              ? Image.network(
                                  storeLogo,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: AppColors.primaryBg,
                                    child: const Icon(LucideIcons.store,
                                        size: 36, color: AppColors.primary),
                                  ),
                                )
                              : Container(
                                  color: AppColors.primaryBg,
                                  child: const Icon(LucideIcons.store,
                                      size: 36, color: AppColors.primary),
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    storeName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    storePhone,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSub,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── 2. Settings Menu Cards ──────────────────────────────────
              SettingsMenuCard(
                title: 'نمط وقالب الهيرو والبانرات',
                subtitle: 'اختيار القالب، إدارة البانرات والشارات',
                icon: LucideIcons.layers,
                badgeText: settings?.heroVariant == 'cinematic-slider'
                    ? 'سينمائي'
                    : 'مفعل',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const HeroSettingsScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),

              SettingsMenuCard(
                title: 'مظهر وألوان المتجر',
                subtitle: 'الباليتات الجاهزة وتخصيص كود Hex',
                icon: LucideIcons.palette,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const AppearanceSettingsScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),

              SettingsMenuCard(
                title: 'بيانات وهوية المتجر والشعار',
                subtitle: 'اسم المتجر والوصف والشعار',
                icon: LucideIcons.store,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const IdentitySettingsScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),

              SettingsMenuCard(
                title: 'أرقام التواصل والشبكات',
                subtitle: 'رقم الهاتف، الواتساب، فيسبوك وانستغرام',
                icon: LucideIcons.phone,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const ContactSettingsScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),

              SettingsMenuCard(
                title: 'الشحن والتوصيل (69 ولاية)',
                subtitle: 'أسعار التوصيل للمنزل والمكتب ورفع JSON',
                icon: LucideIcons.truck,
                badgeText: '69 ولاية',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const ShippingSettingsScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),

              SettingsMenuCard(
                title: 'كوبونات وقسائم التخفيض',
                subtitle: 'إنشاء وإدارة أكواد الخصم ونسب التخفيض للزبائن',
                icon: LucideIcons.ticket,
                badgeText: 'تخفيضات 🎟️',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const CouponsSettingsScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),

              SettingsMenuCard(
                title: 'الإشعارات والتنبيهات الفورية',
                subtitle: 'تنبيهات الطلبيات، الصوت، واختبار التوصيل',
                icon: LucideIcons.bell,
                badgeText: 'نشط ⚡',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const NotificationsSettingsScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),

              SettingsMenuCard(
                title: 'وضع الصيانة والتوقف المؤقت',
                subtitle: isMaintenance
                    ? '⚠️ المتجر متوقف حالياً عن استقبال الطلبات'
                    : 'المتجر نشط ويستقبل الطلبات',
                icon: LucideIcons.alertTriangle,
                isWarning: isMaintenance,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const MaintenanceSettingsScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),

              SettingsMenuCard(
                title: 'حول لوحة التحكم',
                subtitle: 'الإصدار، حالة الاتصال ومستودع الكود',
                icon: LucideIcons.info,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const AboutSettingsScreen()),
                  );
                },
              ),
              const SizedBox(height: 24),

              // ── 3. Logout Button ────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleLogout(context),
                  icon: const Icon(LucideIcons.logOut, size: 18),
                  label: const Text('تسجيل الخروج',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
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
