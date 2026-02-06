import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Context Aware card showing health tracking progress
class ContextAwareCard extends StatelessWidget {
  final int reportCount;
  final List<String> trackedValues;
  final List<String> recentMonths;

  const ContextAwareCard({
    super.key,
    required this.reportCount,
    required this.trackedValues,
    required this.recentMonths,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Background decorative icon
          Positioned(
            right: -10,
            top: 10,
            child: Opacity(
              opacity: 0.2,
              child: FaIcon(
                FontAwesomeIcons.brain,
                size: 80,
                color: AppColors.white,
              ),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label
              Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.wandMagicSparkles,
                    size: 16,
                    color: AppColors.white.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'CONTEXT AWARE',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                'Tracking your progress',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Description
              RichText(
                text: TextSpan(
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white.withValues(alpha: 0.9),
                  ),
                  children: [
                    TextSpan(text: 'Based on your last $reportCount reports, we are monitoring your '),
                    TextSpan(
                      text: trackedValues.join(' and '),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Month chips
              if (recentMonths.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: recentMonths.map((month) => _MonthChip(month: month)).toList(),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthChip extends StatelessWidget {
  final String month;

  const _MonthChip({required this.month});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        month,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
