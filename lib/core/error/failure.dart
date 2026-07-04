

// core/error/failure.dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class LocationFailure extends Failure {
  const LocationFailure(super.message);
}

class CityNotFoundFailure extends Failure {
  const CityNotFoundFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class CancelledFailure extends Failure {
  const CancelledFailure(super.message);
}