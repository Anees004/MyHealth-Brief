import 'package:flutter/material.dart';

/// App color palette extracted from designs
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primaryTeal = Color(0xFF00897B);
  static const Color primaryTealLight = Color(0xFF4DB6AC);
  static const Color primaryTealDark = Color(0xFF00695C);

  // Purple Gradient (Context Aware Card)
  static const Color purpleGradientStart = Color(0xFF7C4DFF);
  static const Color purpleGradientEnd = Color(0xFFB388FF);

  // Status Colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningYellow = Color(0xFFFFC107);
  static const Color errorRed = Color(0xFFF44336);
  static const Color infoBlue = Color(0xFF2196F3);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFAFAFA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color divider = Color(0xFFE0E0E0);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Action Card Colors
  static const Color scanCardBackground = Color(0xFFE8F5E9);
  static const Color uploadCardBackground = Color(0xFFEDE7F6);

  // Badge Colors with opacity
  static const Color lowBadgeBackground = Color(0xFFFFEBEE);
  static const Color normalBadgeBackground = Color(0xFFE8F5E9);
  static const Color borderlineBadgeBackground = Color(0xFFFFF8E1);
  static const Color highBadgeBackground = Color(0xFFFFEBEE);

  // Gradients
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [purpleGradientStart, purpleGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [primaryTeal, primaryTealLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
