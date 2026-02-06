import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/health_brief_entity.dart';
import '../repositories/health_brief_repository.dart';

/// Get health brief by ID use case
class GetHealthBriefById implements UseCase<HealthBriefEntity, String> {
  final HealthBriefRepository repository;

  GetHealthBriefById(this.repository);

  @override
  Future<Either<Failure, HealthBriefEntity>> call(String params) {
    return repository.getHealthBriefById(params);
  }
}
