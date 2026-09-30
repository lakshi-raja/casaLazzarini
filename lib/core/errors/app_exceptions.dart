class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => 'AppException: $message';
}

class AuthenticationException extends AppException {
  const AuthenticationException(super.message);

  @override
  String toString() => 'AuthenticationException: $message';
}

class AuthorizationException extends AppException {
  const AuthorizationException(super.message);

  @override
  String toString() => 'AuthorizationException: $message';
}

class BookingConflictException extends AppException {
  const BookingConflictException(super.message);

  @override
  String toString() => 'BookingConflictException: $message';
}

class NetworkException extends AppException {
  const NetworkException(super.message);

  @override
  String toString() => 'NetworkException: $message';
}

class UnexpectedException extends AppException {
  const UnexpectedException(super.message);

  @override
  String toString() => 'UnexpectedException: $message';
}
