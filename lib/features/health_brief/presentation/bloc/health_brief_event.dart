part of 'health_brief_bloc.dart';

/// Health Brief events
abstract class HealthBriefEvent extends Equatable {
  const HealthBriefEvent();

  @override
  List<Object?> get props => [];
}

/// Analyze document
class HealthBriefAnalyzeRequested extends HealthBriefEvent {
  final String userId;
  final File document;
  final bool isPdf;

  const HealthBriefAnalyzeRequested({
    required this.userId,
    required this.document,
    required this.isPdf,
  });

  @override
  List<Object> get props => [userId, document, isPdf];
}

/// Load health briefs
class HealthBriefLoadRequested extends HealthBriefEvent {
  final String userId;
  final int? limit;

  const HealthBriefLoadRequested({
    required this.userId,
    this.limit,
  });

  @override
  List<Object?> get props => [userId, limit];
}

/// Load health brief by ID
class HealthBriefLoadByIdRequested extends HealthBriefEvent {
  final String id;

  const HealthBriefLoadByIdRequested(this.id);

  @override
  List<Object> get props => [id];
}

/// Change view mode (Simple/Clinical)
class HealthBriefViewModeChanged extends HealthBriefEvent {
  final bool isSimpleView;

  const HealthBriefViewModeChanged(this.isSimpleView);

  @override
  List<Object> get props => [isSimpleView];
}
