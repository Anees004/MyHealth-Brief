import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/health_brief_entity.dart';

/// Health Brief repository interface
abstract class HealthBriefRepository {
  /// Analyze a document and generate health brief
  Future<Either<Failure, HealthBriefEntity>> analyzeDocument({
    required String userId,
    required File document,
    required bool isPdf,
  });

  /// Get all health briefs for a user
  Future<Either<Failure, List<HealthBriefEntity>>> getHealthBriefs({
    required String userId,
    int? limit,
  });

  /// Get a specific health brief by ID
  Future<Either<Failure, HealthBriefEntity>> getHealthBriefById(String id);

  /// Delete a health brief
  Future<Either<Failure, void>> deleteHealthBrief(String id);

  /// Stream of health briefs
  Stream<List<HealthBriefEntity>> watchHealthBriefs(String userId);
}
