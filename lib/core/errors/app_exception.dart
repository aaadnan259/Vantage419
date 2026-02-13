/// Base class for all app-specific exceptions.
abstract class AppException implements Exception {
  const AppException(this.message, [this.originalError]);

  final String message;
  final Object? originalError;

  @override
  String toString() =>
      '$runtimeType: $message${originalError != null ? ' ($originalError)' : ''}';
}

/// Thrown when data operations fail.
class RepositoryException extends AppException {
  const RepositoryException(super.message, [super.originalError]);
}

/// Thrown when service operations fail.
class ServiceException extends AppException {
  const ServiceException(super.message, [super.originalError]);
}
