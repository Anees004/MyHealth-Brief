import 'package:equatable/equatable.dart';

/// Base failure class for domain layer errors
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.code,
  });
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Failed to load cached data.',
    super.code,
  });
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});

  factory AuthFailure.invalidEmail() => const AuthFailure(
        message: 'The email address is invalid.',
        code: 'invalid-email',
      );

  factory AuthFailure.userNotFound() => const AuthFailure(
        message: 'No user found with this email.',
        code: 'user-not-found',
      );

  factory AuthFailure.wrongPassword() => const AuthFailure(
        message: 'Incorrect password. Please try again.',
        code: 'wrong-password',
      );

  factory AuthFailure.emailAlreadyInUse() => const AuthFailure(
        message: 'An account already exists with this email.',
        code: 'email-already-in-use',
      );

  factory AuthFailure.weakPassword() => const AuthFailure(
        message: 'Password is too weak. Please use a stronger password.',
        code: 'weak-password',
      );

  factory AuthFailure.userDisabled() => const AuthFailure(
        message: 'This account has been disabled.',
        code: 'user-disabled',
      );

  factory AuthFailure.tooManyRequests() => const AuthFailure(
        message: 'Too many attempts. Please try again later.',
        code: 'too-many-requests',
      );

  factory AuthFailure.cancelled() => const AuthFailure(
        message: 'Sign in was cancelled.',
        code: 'cancelled',
      );

  factory AuthFailure.unknown([String? message]) => AuthFailure(
        message: message ?? 'An unknown error occurred.',
        code: 'unknown',
      );
}

/// Gemini API failures
class GeminiFailure extends Failure {
  const GeminiFailure({required super.message, super.code});

  factory GeminiFailure.invalidResponse() => const GeminiFailure(
        message: 'Failed to parse the AI response.',
        code: 'invalid-response',
      );

  factory GeminiFailure.apiError(String message) => GeminiFailure(
        message: message,
        code: 'api-error',
      );

  factory GeminiFailure.timeout() => const GeminiFailure(
        message: 'The request timed out. Please try again.',
        code: 'timeout',
      );

  factory GeminiFailure.contentBlocked() => const GeminiFailure(
        message: 'Content was blocked by safety filters.',
        code: 'content-blocked',
      );
}

/// Storage failures
class StorageFailure extends Failure {
  const StorageFailure({required super.message, super.code});

  factory StorageFailure.uploadFailed() => const StorageFailure(
        message: 'Failed to upload file. Please try again.',
        code: 'upload-failed',
      );

  factory StorageFailure.downloadFailed() => const StorageFailure(
        message: 'Failed to download file.',
        code: 'download-failed',
      );

  factory StorageFailure.fileTooLarge() => const StorageFailure(
        message: 'File is too large. Maximum size is 10MB.',
        code: 'file-too-large',
      );
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}
