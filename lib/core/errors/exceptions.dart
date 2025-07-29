class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  
  const NetworkException(this.message, [this.statusCode]);
  
  @override
  String toString() => 'NetworkException: $message';
}

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  
  const ServerException(this.message, [this.statusCode]);
  
  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  final String message;
  
  const CacheException(this.message);
  
  @override
  String toString() => 'CacheException: $message';
}

class ValidationException implements Exception {
  final String message;
  
  const ValidationException(this.message);
  
  @override
  String toString() => 'ValidationException: $message';
}

class PermissionException implements Exception {
  final String message;
  
  const PermissionException(this.message);
  
  @override
  String toString() => 'PermissionException: $message';
}

class VinDecodingException implements Exception {
  final String message;
  
  const VinDecodingException(this.message);
  
  @override
  String toString() => 'VinDecodingException: $message';
}

class DatabaseException implements Exception {
  final String message;
  final String? code;
  
  const DatabaseException(this.message, [this.code]);
  
  @override
  String toString() => 'DatabaseException: $message';
}

class ImageProcessingException implements Exception {
  final String message;
  
  const ImageProcessingException(this.message);
  
  @override
  String toString() => 'ImageProcessingException: $message';
}

class NotFoundException implements Exception {
  final String message;
  
  const NotFoundException(this.message);
  
  @override
  String toString() => 'NotFoundException: $message';
}