import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/health_brief/domain/entities/health_brief_entity.dart';
import 'range_progress_bar.dart';
import 'status_badge.dart';

/// Card displaying a single finding from health report
class FindingCard extends StatefulWidget {
  final FindingEntity finding;
  final bool showClinicalDetails;

  const FindingCard({
    super.key,
    required this.finding,
    this.showClinicalDetails = false,
  });

  @override
  State<FindingCard> createState() => _FindingCardState();
}

class _FindingCardState extends State<FindingCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final hasDetails = widget.showClinicalDetails &&
        (widget.finding.clinicalSignificance != null ||
            (widget.finding.doctorQuestions?.isNotEmpty ?? false));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasDetails ? () => setState(() => _isExpanded = !_isExpanded) : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.finding.name,
                            style: AppTextStyles.h4.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: widget.finding.value.toStringAsFixed(1),
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ${widget.finding.unit}',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(status: widget.finding.status),
                  ],
                ),
                const SizedBox(height: 12),
                // Progress bar
                RangeProgressBar(
                  value: widget.finding.value,
                  minRange: widget.finding.minRange,
                  maxRange: widget.finding.maxRange,
                  status: widget.finding.status,
                ),
                // Clinical details (expandable)
                if (hasDetails) ...[
                  const SizedBox(height: 8),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: _buildClinicalDetails(),
                    crossFadeState: _isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 200),
                  ),
                  // Expand indicator
                  Center(
                    child: FaIcon(
                      _isExpanded
                          ? FontAwesomeIcons.chevronUp
                          : FontAwesomeIcons.chevronDown,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClinicalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24),
        // Clinical Significance
        if (widget.finding.clinicalSignificance != null) ...[
          Text(
            'CLINICAL SIGNIFICANCE',
            style: AppTextStyles.overline.copyWith(
              color: AppColors.primaryTeal,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.finding.clinicalSignificance!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
        // Doctor Questions
        if (widget.finding.doctorQuestions?.isNotEmpty ?? false) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.comment,
                      size: 16,
                      color: AppColors.primaryTeal,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ask your doctor',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primaryTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...widget.finding.doctorQuestions!.map(
                  (question) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            question,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
