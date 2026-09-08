import 'package:flutter/material.dart';

class AppColors {
  // Main Theme & Backgrounds
  static const Color bg = Color(0xFFF8F9FE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFECEEF6);
  static const Color divider = Color(0xFFF1F3F9);

  // Brand Primary (Soft Modern Lavender/Indigo)
  static const Color primary = Color(0xFF5C6AC4);
  static const Color primaryBg = Color(0xFFEEF0FF);
  static const Color primaryDark = Color(0xFF4B55A5);
  static const Color primaryLight = Color(0xFF7E8DE0);

  // Typography
  static const Color text = Color(0xFF1E1B4B);
  static const Color textSub = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Semantic Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successBg = Color(0xFFECFDF5);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFFFFFBEB);

  static const Color danger = Color(0xFFEF4444);
  static const Color dangerBg = Color(0xFFFEF2F2);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoBg = Color(0xFFEFF6FF);

  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleBg = Color(0xFFF5F3FF);

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
