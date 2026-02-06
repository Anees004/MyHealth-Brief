import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/health_brief/domain/entities/health_brief_entity.dart';

/// Status badge widget for findings (Low, Normal, Borderline, High)
class StatusBadge extends StatelessWidget {
  final FindingStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Text(
        status.displayName,
        style: AppTextStyles.labelMedium.copyWith(
          color: _textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color get _backgroundColor {
    switch (status) {
      case FindingStatus.low:
        return AppColors.lowBadgeBackground;
      case FindingStatus.normal:
        return AppColors.normalBadgeBackground;
      case FindingStatus.borderline:
        return AppColors.borderlineBadgeBackground;
      case FindingStatus.high:
        return AppColors.highBadgeBackground;
    }
  }

  Color get _borderColor {
    switch (status) {
      case FindingStatus.low:
        return AppColors.errorRed.withValues(alpha: 0.3);
      case FindingStatus.normal:
        return AppColors.successGreen.withValues(alpha: 0.3);
      case FindingStatus.borderline:
        return AppColors.warningYellow.withValues(alpha: 0.3);
      case FindingStatus.high:
        return AppColors.errorRed.withValues(alpha: 0.3);
    }
  }

  Color get _textColor {
    switch (status) {
      case FindingStatus.low:
        return AppColors.errorRed;
      case FindingStatus.normal:
        return AppColors.successGreen;
      case FindingStatus.borderline:
        return const Color(0xFFE65100); // Darker orange for readability
      case FindingStatus.high:
        return AppColors.errorRed;
    }
  }
}
