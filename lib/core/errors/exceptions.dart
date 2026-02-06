/// Base exception class for data layer errors
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({required this.message, this.code});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Server exceptions
class ServerException extends AppException {
  const ServerException({required super.message, super.code});
}

/// Network exceptions
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection',
    super.code,
  });
}

/// Cache exceptions
class CacheException extends AppException {
  const CacheException({
    super.message = 'Cache error',
    super.code,
  });
}

/// Authentication exceptions
class AuthException extends AppException {
  const AuthException({required super.message, super.code});
}

/// Gemini API exceptions
class GeminiException extends AppException {
  const GeminiException({required super.message, super.code});
}

/// Storage exceptions
class StorageException extends AppException {
  const StorageException({required super.message, super.code});
}

/// Validation exceptions
class ValidationException extends AppException {
  const ValidationException({required super.message, super.code});
}
