abstract class Failure {
  final String message;
  final int? code;
  
  const Failure(this.message, [this.code]);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message, [int? code]) : super(message, code);
}

class ServerFailure extends Failure {
  const ServerFailure(String message, [int? code]) : super(message, code);
}

class CacheFailure extends Failure {
  const CacheFailure(String message, [int? code]) : super(message, code);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message, [int? code]) : super(message, code);
}

class PermissionFailure extends Failure {
  const PermissionFailure(String message, [int? code]) : super(message, code);
}

class VinDecodingFailure extends Failure {
  const VinDecodingFailure(String message, [int? code]) : super(message, code);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(String message, [int? code]) : super(message, code);
}

class ImageProcessingFailure extends Failure {
  const ImageProcessingFailure(String message, [int? code]) : super(message, code);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(String message, [int? code]) : super(message, code);
}