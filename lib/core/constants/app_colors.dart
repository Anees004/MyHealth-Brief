import 'package:flutter/material.dart';

/// App color palette extracted from the UI designs
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primaryTeal = Color(0xFF00897B);
  static const Color primaryTealLight = Color(0xFF4DB6AC);
  static const Color primaryTealDark = Color(0xFF00695C);

  // Purple Gradient (Context Aware Card)
  static const Color purpleGradientStart = Color(0xFF7C4DFF);
  static const Color purpleGradientEnd = Color(0xFFB388FF);

  // Status Badge Colors
  static const Color statusLow = Color(0xFFE53935);
  static const Color statusLowBackground = Color(0xFFFFEBEE);
  static const Color statusNormal = Color(0xFF43A047);
  static const Color statusNormalBackground = Color(0xFFE8F5E9);
  static const Color statusBorderline = Color(0xFFFFA726);
  static const Color statusBorderlineBackground = Color(0xFFFFF3E0);
  static const Color statusHigh = Color(0xFFE53935);
  static const Color statusHighBackground = Color(0xFFFFEBEE);

  // Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color darkCard = Color(0xFF1E1E1E);

  // Action Card Colors
  static const Color scanCardBackground = Color(0xFFE0F2F1);
  static const Color uploadCardBackground = Color(0xFFEDE7F6);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Border & Divider
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  // Gemini Summary Card
  static const Color geminiCardBorder = Color(0xFF00897B);
  static const Color geminiCardBackground = Color(0xFFE0F2F1);

  // Range Progress Bar
  static const Color progressBackground = Color(0xFFE0E0E0);
  static const Color progressLow = Color(0xFFE53935);
  static const Color progressNormal = Color(0xFF43A047);
  static const Color progressBorderline = Color(0xFFFFA726);
  static const Color progressHigh = Color(0xFFE53935);

  // Disclaimer
  static const Color disclaimerBackground = Color(0xFFFFF8E1);
  static const Color disclaimerBorder = Color(0xFFFFE082);
  static const Color disclaimerIcon = Color(0xFFFFA000);
}
