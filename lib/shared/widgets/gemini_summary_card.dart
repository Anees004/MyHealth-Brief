import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Card displaying Gemini AI summary with teal accent
class GeminiSummaryCard extends StatelessWidget {
  final String summary;

  const GeminiSummaryCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Teal accent bar
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: AppColors.primaryTeal,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.wandMagicSparkles,
                          size: 18,
                          color: AppColors.primaryTeal,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Gemini Summary',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Summary text
                    Text(
                      summary,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
