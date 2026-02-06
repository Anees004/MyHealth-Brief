import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

/// Base use case interface with parameters
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Use case with no parameters
abstract class UseCaseNoParams<T> {
  Future<Either<Failure, T>> call();
}

/// Use case with stream return type
abstract class StreamUseCase<T, Params> {
  Stream<Either<Failure, T>> call(Params params);
}

/// No parameters class
class NoParams {
  const NoParams();
}
