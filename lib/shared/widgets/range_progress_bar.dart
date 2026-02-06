import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../features/health_brief/domain/entities/health_brief_entity.dart';

/// Progress bar showing where a value falls within a range
class RangeProgressBar extends StatelessWidget {
  final double value;
  final double minRange;
  final double maxRange;
  final FindingStatus status;

  const RangeProgressBar({
    super.key,
    required this.value,
    required this.minRange,
    required this.maxRange,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate the position of the value indicator
    final range = maxRange - minRange;
    final normalizedValue = range > 0 ? (value - minRange) / range : 0.5;
    final indicatorPosition = normalizedValue.clamp(0.0, 1.0);

    return SizedBox(
      height: 8,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final indicatorX = width * indicatorPosition;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Background track
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              // Filled portion
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  height: 6,
                  width: indicatorX,
                  decoration: BoxDecoration(
                    color: _fillColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              // Value indicator
              Positioned(
                left: indicatorX - 4,
                top: -1,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _fillColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _fillColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color get _fillColor {
    switch (status) {
      case FindingStatus.low:
        return AppColors.errorRed;
      case FindingStatus.normal:
        return AppColors.successGreen;
      case FindingStatus.borderline:
        return AppColors.warningYellow;
      case FindingStatus.high:
        return AppColors.errorRed;
    }
  }
}
