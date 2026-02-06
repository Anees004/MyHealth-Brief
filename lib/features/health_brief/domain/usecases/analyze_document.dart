import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/health_brief_entity.dart';
import '../repositories/health_brief_repository.dart';

/// Analyze document use case
class AnalyzeDocument implements UseCase<HealthBriefEntity, AnalyzeDocumentParams> {
  final HealthBriefRepository repository;

  AnalyzeDocument(this.repository);

  @override
  Future<Either<Failure, HealthBriefEntity>> call(AnalyzeDocumentParams params) {
    return repository.analyzeDocument(
      userId: params.userId,
      document: params.document,
      isPdf: params.isPdf,
    );
  }
}

/// Parameters for analyze document
class AnalyzeDocumentParams extends Equatable {
  final String userId;
  final File document;
  final bool isPdf;

  const AnalyzeDocumentParams({
    required this.userId,
    required this.document,
    required this.isPdf,
  });

  @override
  List<Object> get props => [userId, document, isPdf];
}
