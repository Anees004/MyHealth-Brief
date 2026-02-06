part of 'health_brief_bloc.dart';

/// Health Brief states
abstract class HealthBriefState extends Equatable {
  const HealthBriefState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class HealthBriefInitial extends HealthBriefState {}

/// Loading state
class HealthBriefLoading extends HealthBriefState {}

/// Analyzing document state
class HealthBriefAnalyzing extends HealthBriefState {}

/// Document analyzed successfully
class HealthBriefAnalyzed extends HealthBriefState {
  final HealthBriefEntity brief;

  const HealthBriefAnalyzed(this.brief);

  @override
  List<Object> get props => [brief];
}

/// Health briefs loaded
class HealthBriefsLoaded extends HealthBriefState {
  final List<HealthBriefEntity> briefs;

  const HealthBriefsLoaded(this.briefs);

  @override
  List<Object> get props => [briefs];
}

/// Single health brief detail loaded
class HealthBriefDetailLoaded extends HealthBriefState {
  final HealthBriefEntity brief;
  final bool isSimpleView;

  const HealthBriefDetailLoaded(
    this.brief, {
    this.isSimpleView = true,
  });

  @override
  List<Object> get props => [brief, isSimpleView];
}

/// Error state
class HealthBriefError extends HealthBriefState {
  final String message;

  const HealthBriefError(this.message);

  @override
  List<Object> get props => [message];
}
