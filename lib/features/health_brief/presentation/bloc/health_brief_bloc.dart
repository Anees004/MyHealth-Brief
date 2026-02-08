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

  /// Keeps the last analyzed brief so we can show it in the list when Firestore load fails (e.g. index).
  HealthBriefEntity? _lastAnalyzedBrief;

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
      (brief) {
        _lastAnalyzedBrief = brief;
        emit(HealthBriefAnalyzed(brief));
      },
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
      (failure) {
        // If we just analyzed a brief but list load failed (e.g. Firestore index),
        // show the new brief so the user can still open it. Otherwise keep previous list if any.
        if (_lastAnalyzedBrief != null) {
          emit(HealthBriefsLoaded([_lastAnalyzedBrief!]));
        } else {
          final current = state;
          if (current is HealthBriefsLoaded) {
            emit(HealthBriefsLoaded(current.briefs));
          } else {
            emit(HealthBriefError(failure.message));
          }
        }
      },
      (briefs) {
        _lastAnalyzedBrief = null;
        emit(HealthBriefsLoaded(briefs));
      },
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
