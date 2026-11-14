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

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message);
}

class ForbiddenException extends AppException {
  const ForbiddenException(super.message);
}

class RateLimitException extends AppException {
  const RateLimitException(super.message);
}

class ValidationException extends AppException {
  final Map<String, String> fieldErrors;

  const ValidationException(super.message, {this.fieldErrors = const {}});
}

class ConflictException extends AppException {
  const ConflictException(super.message);
}

/// Permission related exceptions
class PermissionException extends AppException {
  const PermissionException(super.message);
}

/// Location related exceptions
enum LocationIssue { serviceDisabled, denied, deniedForever, timeout, unknown }

class LocationException extends AppException {
  final LocationIssue issue;
  const LocationException(super.message, {this.issue = LocationIssue.unknown});
}
