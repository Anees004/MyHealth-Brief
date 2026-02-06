import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../health_brief/domain/entities/health_brief_entity.dart';
import '../../../health_brief/presentation/bloc/health_brief_bloc.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  late HealthBriefBloc _healthBriefBloc;

  @override
  void initState() {
    super.initState();
    _healthBriefBloc = sl<HealthBriefBloc>();
    _loadBriefs();
  }

  void _loadBriefs() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _healthBriefBloc.add(HealthBriefLoadRequested(
        userId: authState.user.id,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _healthBriefBloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          title: const Text(AppStrings.timeline),
          elevation: 0,
        ),
        body: BlocBuilder<HealthBriefBloc, HealthBriefState>(
          builder: (context, state) {
            if (state is HealthBriefLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is HealthBriefError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.circleExclamation,
                      size: 48,
                      color: AppColors.errorRed,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadBriefs,
                      child: const Text(AppStrings.tryAgain),
                    ),
                  ],
                ),
              );
            }

            if (state is HealthBriefsLoaded) {
              if (state.briefs.isEmpty) {
                return _buildEmptyState();
              }
              return _buildTimeline(state.briefs);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildTimeline(List<HealthBriefEntity> briefs) {
    // Group briefs by month
    final groupedBriefs = <String, List<HealthBriefEntity>>{};
    for (final brief in briefs) {
      final monthYear = brief.reportDate.toMonthYear();
      groupedBriefs.putIfAbsent(monthYear, () => []).add(brief);
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadBriefs();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: groupedBriefs.length,
        itemBuilder: (context, index) {
          final monthYear = groupedBriefs.keys.elementAt(index);
          final monthBriefs = groupedBriefs[monthYear]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month header
              Padding(
                padding: EdgeInsets.only(bottom: 16, top: index > 0 ? 24.0 : 0.0),
                child: Text(
                  monthYear,
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              // Briefs for this month
              ...monthBriefs.map(
                (brief) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TimelineBriefCard(
                    brief: brief,
                    onTap: () => context.push(AppRoutes.briefDetailPath(brief.id)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.clockRotateLeft,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No health briefs yet',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your health reports will appear here\nafter you scan or upload them',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.home),
              icon: const FaIcon(FontAwesomeIcons.plus),
              label: const Text('Add Report'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineBriefCard extends StatelessWidget {
  final HealthBriefEntity brief;
  final VoidCallback onTap;

  const _TimelineBriefCard({
    required this.brief,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final abnormalCount = brief.abnormalFindingsCount;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              // Date indicator
              Container(
                width: 56,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      brief.reportDate.day.toString(),
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.primaryTeal,
                      ),
                    ),
                    Text(
                      brief.reportDate.toMonthShort(),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brief.title,
                      style: AppTextStyles.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (brief.labSource != null)
                      Text(
                        brief.labSource!,
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _InfoChip(
                          icon: FontAwesomeIcons.chartLine,
                          label: '${brief.findings.length} findings',
                        ),
                        if (abnormalCount > 0) ...[
                          const SizedBox(width: 8),
                          _InfoChip(
                            icon: FontAwesomeIcons.triangleExclamation,
                            label: '$abnormalCount attention',
                            isWarning: true,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Chevron
              FaIcon(
                FontAwesomeIcons.chevronRight,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isWarning;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = isWarning ? AppColors.warningYellow : AppColors.primaryTeal;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            icon,
            size: 12,
            color: chipColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
