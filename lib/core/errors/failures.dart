/// Base failure class
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

/// Network related failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure(super.message);
}

/// Data related failures
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class ConflictFailure extends Failure {
  const ConflictFailure(super.message);
}

class ValidationFailure extends Failure {
  final Map<String, String> fieldErrors;

  const ValidationFailure(super.message, {this.fieldErrors = const {}});
}

/// Permission related failures
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// Location related failures
class LocationFailure extends Failure {
  const LocationFailure(super.message);
}
