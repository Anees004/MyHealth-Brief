import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/health_brief_entity.dart';
import '../../domain/usecases/analyze_document.dart';
import '../../domain/usecases/get_health_brief_by_id.dart';
import '../../domain/usecases/get_health_briefs.dart';

part 'health_brief_event.dart';
part 'health_brief_state.dart';

/// Health Brief BLoC
class HealthBriefBloc extends Bloc<HealthBriefEvent, HealthBriefState> {
  final AnalyzeDocument analyzeDocument;
  final GetHealthBriefs getHealthBriefs;
  final GetHealthBriefById getHealthBriefById;

  HealthBriefBloc({
    required this.analyzeDocument,
    required this.getHealthBriefs,
    required this.getHealthBriefById,
  }) : super(HealthBriefInitial()) {
    on<HealthBriefAnalyzeRequested>(_onAnalyzeDocument);
    on<HealthBriefLoadRequested>(_onLoadHealthBriefs);
    on<HealthBriefLoadByIdRequested>(_onLoadHealthBriefById);
    on<HealthBriefViewModeChanged>(_onViewModeChanged);
  }

  Future<void> _onAnalyzeDocument(
    HealthBriefAnalyzeRequested event,
    Emitter<HealthBriefState> emit,
  ) async {
    emit(HealthBriefAnalyzing());

    final result = await analyzeDocument(AnalyzeDocumentParams(
      userId: event.userId,
      document: event.document,
      isPdf: event.isPdf,
    ));

    result.fold(
      (failure) => emit(HealthBriefError(failure.message)),
      (brief) => emit(HealthBriefAnalyzed(brief)),
    );
  }

  Future<void> _onLoadHealthBriefs(
    HealthBriefLoadRequested event,
    Emitter<HealthBriefState> emit,
  ) async {
    emit(HealthBriefLoading());

    final result = await getHealthBriefs(GetHealthBriefsParams(
      userId: event.userId,
      limit: event.limit,
    ));

    result.fold(
      (failure) => emit(HealthBriefError(failure.message)),
      (briefs) => emit(HealthBriefsLoaded(briefs)),
    );
  }

  Future<void> _onLoadHealthBriefById(
    HealthBriefLoadByIdRequested event,
    Emitter<HealthBriefState> emit,
  ) async {
    emit(HealthBriefLoading());

    final result = await getHealthBriefById(event.id);

    result.fold(
      (failure) => emit(HealthBriefError(failure.message)),
      (brief) => emit(HealthBriefDetailLoaded(brief)),
    );
  }

  void _onViewModeChanged(
    HealthBriefViewModeChanged event,
    Emitter<HealthBriefState> emit,
  ) {
    if (state is HealthBriefDetailLoaded) {
      final currentState = state as HealthBriefDetailLoaded;
      emit(HealthBriefDetailLoaded(
        currentState.brief,
        isSimpleView: event.isSimpleView,
      ));
    }
  }
}
