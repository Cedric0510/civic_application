abstract class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'A network error occurred.']);
}

class DatabaseException extends AppException {
  const DatabaseException([super.message = 'A database error occurred.']);
}

class AuthException extends AppException {
  const AuthException([super.message = 'An authentication error occurred.']);
}

class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'The requested resource was not found.',
  ]);
}
