import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../repositories/auth_repository.dart';

/// Delete account and all user data use case
class DeleteAccount implements UseCaseNoParams<void> {
  final AuthRepository repository;

  DeleteAccount(this.repository);

  @override
  Future<Either<Failure, void>> call() {
    return repository.deleteAccount();
  }
}
