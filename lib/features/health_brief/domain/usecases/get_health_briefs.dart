import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/health_brief_entity.dart';
import '../repositories/health_brief_repository.dart';

/// Get health briefs use case
class GetHealthBriefs implements UseCase<List<HealthBriefEntity>, GetHealthBriefsParams> {
  final HealthBriefRepository repository;

  GetHealthBriefs(this.repository);

  @override
  Future<Either<Failure, List<HealthBriefEntity>>> call(GetHealthBriefsParams params) {
    return repository.getHealthBriefs(
      userId: params.userId,
      limit: params.limit,
    );
  }
}

/// Parameters for get health briefs
class GetHealthBriefsParams extends Equatable {
  final String userId;
  final int? limit;

  const GetHealthBriefsParams({
    required this.userId,
    this.limit,
  });

  @override
  List<Object?> get props => [userId, limit];
}
