/// Base exception class
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);
  
  @override
  String toString() => message;
}

/// Network related exceptions
class NetworkException extends AppException {
  const NetworkException(super.message);
}

class ServerException extends AppException {
  const ServerException(super.message);
}

class TimeoutException extends AppException {
  const TimeoutException(super.message);
}

/// Data related exceptions
class CacheException extends AppException {
  const CacheException(super.message);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

/// Permission related exceptions
class PermissionException extends AppException {
  const PermissionException(super.message);
}

/// Location related exceptions
class LocationException extends AppException {
  const LocationException(super.message);
}

