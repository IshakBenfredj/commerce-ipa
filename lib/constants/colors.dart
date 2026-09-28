import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Main Theme & Backgrounds (Light)
  static const Color bg = Color(0xFFF8F9FE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFECEEF6);
  static const Color divider = Color(0xFFF1F3F9);

  // Main Theme & Backgrounds (Dark)
  static const Color darkBg = Color(0xFF0B0C10);
  static const Color darkSurface = Color(0xFF15161E);
  static const Color darkCard = Color(0xFF181A24);
  static const Color darkBorder = Color(0xFF252736);
  static const Color darkDivider = Color(0xFF1F2231);

  // Brand Primary (Soft Modern Lavender/Indigo)
  static const Color primary = Color(0xFF5C6AC4);
  static const Color primaryBg = Color(0xFFEEF0FF);
  static const Color darkPrimaryBg = Color(0xFF1F2238);
  static const Color primaryDark = Color(0xFF4B55A5);
  static const Color primaryLight = Color(0xFF7E8DE0);

  // Typography (Light)
  static const Color text = Color(0xFF1E1B4B);
  static const Color textSub = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Typography (Dark)
  static const Color darkText = Color(0xFFF3F4F6);
  static const Color darkTextSub = Color(0xFF9CA3AF);
  static const Color darkTextMuted = Color(0xFF6B7280);

  // Semantic Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successBg = Color(0xFFECFDF5);
  static const Color darkSuccessBg = Color(0xFF064E3B);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color darkWarningBg = Color(0xFF451A03);

  static const Color danger = Color(0xFFEF4444);
  static const Color dangerBg = Color(0xFFFEF2F2);
  static const Color darkDangerBg = Color(0xFF7F1D1D);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoBg = Color(0xFFEFF6FF);
  static const Color darkInfoBg = Color(0xFF0C4A6E);

  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleBg = Color(0xFFF5F3FF);
  static const Color darkPurpleBg = Color(0xFF3B0764);

  // Context-aware Helpers
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color bgOf(BuildContext context) =>
      isDark(context) ? darkBg : bg;

  static Color surfaceOf(BuildContext context) =>
      isDark(context) ? darkSurface : surface;

  static Color cardOf(BuildContext context) =>
      isDark(context) ? darkCard : card;

  static Color borderOf(BuildContext context) =>
      isDark(context) ? darkBorder : border;

  static Color dividerOf(BuildContext context) =>
      isDark(context) ? darkDivider : divider;

  static Color textOf(BuildContext context) =>
      isDark(context) ? darkText : text;

  static Color textSubOf(BuildContext context) =>
      isDark(context) ? darkTextSub : textSub;

  static Color textMutedOf(BuildContext context) =>
      isDark(context) ? darkTextMuted : textMuted;

  static Color primaryBgOf(BuildContext context) =>
      isDark(context) ? darkPrimaryBg : primaryBg;

  // Status mapping helper
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return warning;
      case 'confirmed':
        return info;
      case 'shipped':
        return purple;
      case 'delivered':
        return success;
      case 'cancelled':
      case 'returned':
        return danger;
      default:
        return textSub;
    }
  }

  static Color getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return warningBg;
      case 'confirmed':
        return infoBg;
      case 'shipped':
        return purpleBg;
      case 'delivered':
        return successBg;
      case 'cancelled':
      case 'returned':
        return dangerBg;
      default:
        return border;
    }
  }

  static Color statusBgOf(BuildContext context, String status) {
    if (isDark(context)) {
      switch (status.toLowerCase()) {
        case 'pending':
          return darkWarningBg;
        case 'confirmed':
          return darkInfoBg;
        case 'shipped':
          return darkPurpleBg;
        case 'delivered':
          return darkSuccessBg;
        case 'cancelled':
        case 'returned':
          return darkDangerBg;
        default:
          return darkBorder;
      }
    }
    return getStatusBgColor(status);
  }

  static String getStatusLabelAr(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'قيد الانتظار';
      case 'confirmed':
        return 'مؤكدة';
      case 'shipped':
        return 'تم الشحن';
      case 'delivered':
        return 'تم التوصيل';
      case 'cancelled':
        return 'ملغاة';
      case 'returned':
        return 'مسترجعة';
      default:
        return status;
    }
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.text),
        titleTextStyle: TextStyle(
          color: AppColors.text,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkText,
        outline: AppColors.darkBorder,
      ),
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: AppColors.darkText,
        displayColor: AppColors.darkText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.darkText),
        titleTextStyle: TextStyle(
          color: AppColors.darkText,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
      ),
    );
  }
}
