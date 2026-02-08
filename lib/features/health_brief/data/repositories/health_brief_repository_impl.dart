import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/health_brief_entity.dart';
import '../../domain/repositories/health_brief_repository.dart';
import '../datasources/gemini_datasource.dart';
import '../datasources/health_brief_remote_datasource.dart';
import '../datasources/local_report_storage.dart';
import '../models/health_brief_model.dart';

/// Health Brief repository implementation.
/// Reports are stored locally only (no cloud upload) for privacy.
class HealthBriefRepositoryImpl implements HealthBriefRepository {
  final GeminiDataSource geminiDataSource;
  final LocalReportStorage localReportStorage;
  final HealthBriefRemoteDataSource remoteDataSource;

  HealthBriefRepositoryImpl({
    required this.geminiDataSource,
    required this.localReportStorage,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, HealthBriefEntity>> analyzeDocument({
    required String userId,
    required File document,
    required bool isPdf,
  }) async {
    try {
      const uuid = Uuid();
      final briefId = uuid.v4();

      // Save report locally only (no upload to cloud – keeps health data private)
      await localReportStorage.saveDocument(
        briefId: briefId,
        file: document,
        isPdf: isPdf,
      );

      // Analyze document with Gemini (content sent for analysis only; not stored by us in cloud)
      final analysisResult = await geminiDataSource.analyzeDocument(
        document: document,
        isPdf: isPdf,
      );

      // Brief metadata + AI results saved to Firestore; document stays on device
      final healthBrief = HealthBriefModel.fromGeminiResponse(
        id: briefId,
        userId: userId,
        json: analysisResult,
        documentUrl: null, // Report stored locally only
      );

      await remoteDataSource.saveHealthBrief(healthBrief);

      return Right(healthBrief.toEntity());
    } on GeminiException catch (e) {
      return Left(GeminiFailure(message: e.message, code: e.code));
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on SocketException catch (_) {
      return const Left(NetworkFailure(
        message: 'No internet connection. Please check your network and try again.',
        code: 'network',
      ));
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('SocketException') ||
          msg.contains('Failed host lookup') ||
          msg.contains('ClientException') ||
          msg.contains('nodename nor servname')) {
        return const Left(NetworkFailure(
          message: 'No internet connection. Please check your network and try again.',
          code: 'network',
        ));
      }
      return const Left(ServerFailure(
        message: 'Something went wrong while analyzing. Please try again.',
        code: 'unknown',
      ));
    }
  }

  @override
  Future<Either<Failure, List<HealthBriefEntity>>> getHealthBriefs({
    required String userId,
    int? limit,
  }) async {
    try {
      final briefs = await remoteDataSource.getHealthBriefs(
        userId: userId,
        limit: limit,
      );
      return Right(briefs.map((b) => b.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, HealthBriefEntity>> getHealthBriefById(String id) async {
    try {
      final brief = await remoteDataSource.getHealthBriefById(id);
      return Right(brief.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, void>> deleteHealthBrief(String id) async {
    try {
      await localReportStorage.deleteLocalDocument(id);
      await remoteDataSource.deleteHealthBrief(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    }
  }

  @override
  Stream<List<HealthBriefEntity>> watchHealthBriefs(String userId) {
    return remoteDataSource
        .watchHealthBriefs(userId)
        .map((briefs) => briefs.map((b) => b.toEntity()).toList());
  }
}
