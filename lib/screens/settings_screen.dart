import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/settings_menu_card.dart';
import 'settings/hero_settings_screen.dart';
import 'settings/appearance_settings_screen.dart';
import 'settings/identity_settings_screen.dart';
import 'settings/contact_settings_screen.dart';
import 'settings/shipping_settings_screen.dart';
import 'settings/notifications_settings_screen.dart';
import 'settings/maintenance_settings_screen.dart';
import 'settings/coupons_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'إعدادات المتجر',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textOf(context),
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
                          color: AppColors.surfaceOf(context),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.borderOf(context), width: 2),
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
                                    color: AppColors.primaryBgOf(context),
                                    child: const Icon(LucideIcons.store,
                                        size: 36, color: AppColors.primary),
                                  ),
                                )
                              : Container(
                                  color: AppColors.primaryBgOf(context),
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
                            border: Border.all(
                                color: AppColors.surfaceOf(context),
                                width: 2.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    storeName,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textOf(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    storePhone,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSubOf(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Theme Mode Selector Card (Dark Mode) ──
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  final isDark = themeProvider.isDark(context);
                  final currentMode = themeProvider.themeMode;
                  return Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceOf(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderOf(context)),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF1E1B4B).withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 1.5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBgOf(context),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isDark ? LucideIcons.moon : LucideIcons.sun,
                                size: 20,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              textDirection: TextDirection.rtl,
                              children: [
                                Text(
                                  'مظهر التطبيق (الوضع الداكن)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textOf(context),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isDark
                                      ? 'الوضع الداكن مفعّل'
                                      : 'الوضع الفاتح مفعّل',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSubOf(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E202C)
                                : const Color(0xFFF1F3F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              _buildThemeButton(
                                context: context,
                                label: 'فاتح',
                                icon: LucideIcons.sun,
                                isSelected: currentMode == ThemeMode.light,
                                onTap: () =>
                                    themeProvider.setThemeMode(ThemeMode.light),
                              ),
                              _buildThemeButton(
                                context: context,
                                label: 'داكن',
                                icon: LucideIcons.moon,
                                isSelected: currentMode == ThemeMode.dark,
                                onTap: () =>
                                    themeProvider.setThemeMode(ThemeMode.dark),
                              ),
                              _buildThemeButton(
                                context: context,
                                label: 'تلقائي',
                                icon: LucideIcons.monitor,
                                isSelected: currentMode == ThemeMode.system,
                                onTap: () => themeProvider
                                    .setThemeMode(ThemeMode.system),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

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
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280)),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF6B7280)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
