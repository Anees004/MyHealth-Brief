import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../health_brief/domain/entities/health_brief_entity.dart';
import '../../../health_brief/presentation/bloc/health_brief_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HealthBriefBloc _healthBriefBloc;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _healthBriefBloc = sl<HealthBriefBloc>();
    _loadRecentBriefs();
  }

  void _loadRecentBriefs() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _healthBriefBloc.add(HealthBriefLoadRequested(
        userId: authState.user.id,
        limit: 5,
      ));
    }
  }

  Future<void> _onScanReport() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    
    if (image != null) {
      _analyzeDocument(File(image.path), isPdf: false);
    }
  }

  Future<void> _onUploadPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final isPdf = result.files.single.extension?.toLowerCase() == 'pdf';
      _analyzeDocument(file, isPdf: isPdf);
    }
  }

  void _analyzeDocument(File document, {required bool isPdf}) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _healthBriefBloc.add(HealthBriefAnalyzeRequested(
        userId: authState.user.id,
        document: document,
        isPdf: isPdf,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _healthBriefBloc,
      child: BlocConsumer<HealthBriefBloc, HealthBriefState>(
        listener: (context, state) {
          if (state is HealthBriefAnalyzed) {
            // Navigate to brief detail
            context.push(AppRoutes.briefDetailPath(state.brief.id));
            // Reload recent briefs
            _loadRecentBriefs();
          } else if (state is HealthBriefError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.errorRed,
              ),
            );
          }
        },
        builder: (context, briefState) {
          final isAnalyzing = briefState is HealthBriefAnalyzing;

          return Stack(
            children: [
              Scaffold(
                backgroundColor: AppColors.background,
                body: SafeArea(
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      if (authState is! AuthAuthenticated) {
                        return const SizedBox.shrink();
                      }

                      final user = authState.user;

                      return RefreshIndicator(
                        onRefresh: () async {
                          _loadRecentBriefs();
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '${AppStrings.hello}, ${user.firstName}',
                                            style: AppTextStyles.h2,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            '👋',
                                            style: TextStyle(fontSize: 24),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        AppStrings.yourHealthBriefReady,
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  UserAvatar(
                                    imageUrl: user.photoUrl,
                                    initials: user.initials,
                                    size: 44,
                                    onTap: () => context.go(AppRoutes.profile),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Context Aware Card
                              _buildContextAwareCard(briefState),
                              const SizedBox(height: 24),
                              // Action Cards
                              Row(
                                children: [
                                  Expanded(
                                    child: ActionCard.scanReport(
                                      onTap: _onScanReport,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ActionCard.uploadPdf(
                                      onTap: _onUploadPdf,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              // Recent Briefs
                              _buildRecentBriefs(briefState),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Loading overlay
              if (isAnalyzing) const AnalyzingOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContextAwareCard(HealthBriefState state) {
    // Show context aware card with data from recent briefs
    if (state is HealthBriefsLoaded && state.briefs.isNotEmpty) {
      // Extract tracked values from recent briefs
      final trackedValues = <String>{};
      final recentMonths = <String>[];

      for (final brief in state.briefs.take(3)) {
        // Add months
        final month = brief.reportDate.toMonthShort();
        if (!recentMonths.contains(month)) {
          recentMonths.add(month);
        }

        // Find abnormal values
        for (final finding in brief.findings) {
          if (finding.status != FindingStatus.normal) {
            trackedValues.add(finding.name);
          }
        }
      }

      if (trackedValues.isEmpty) {
        trackedValues.addAll(['your health metrics']);
      }

      return ContextAwareCard(
        reportCount: state.briefs.length,
        trackedValues: trackedValues.take(2).toList(),
        recentMonths: recentMonths.take(3).toList(),
      );
    }

    // Default card for new users
    return const ContextAwareCard(
      reportCount: 0,
      trackedValues: ['your health metrics'],
      recentMonths: [],
    );
  }

  Widget _buildRecentBriefs(HealthBriefState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.recentBriefs,
              style: AppTextStyles.h4,
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.timeline),
              child: Text(
                AppStrings.viewAll,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primaryTeal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state is HealthBriefsLoaded) ...[
          if (state.briefs.isEmpty)
            _buildEmptyState()
          else
            ...state.briefs.map(
              (brief) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BriefListItem(
                  brief: brief,
                  onTap: () => context.push(AppRoutes.briefDetailPath(brief.id)),
                ),
              ),
            ),
        ] else if (state is HealthBriefLoading) ...[
          _buildLoadingState(),
        ] else ...[
          _buildEmptyState(),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(
            FontAwesomeIcons.fileLines,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No reports yet',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan or upload your first health report\nto get started',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
    );
  }
}
