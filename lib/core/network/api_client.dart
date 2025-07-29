import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../errors/exceptions.dart';

class ApiClient {
  late final Dio _dio;
  
  ApiClient() {
    _dio = Dio(BaseOptions(
      connectTimeout: ApiEndpoints.connectTimeout,
      receiveTimeout: ApiEndpoints.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        final exception = _handleDioError(error);
        handler.reject(DioException(
          requestOptions: error.requestOptions,
          error: exception,
        ));
      },
    ));
  }
  
  /// GET request
  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        url,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// POST request
  Future<Response> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// PUT request
  Future<Response> put(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// DELETE request
  Future<Response> delete(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// Handle Dio errors and convert to custom exceptions
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('Connection timeout');
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 
                       error.response?.statusMessage ?? 
                       'Unknown server error';
        
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            if (statusCode == 404) {
              return NotFoundException(message);
            }
            return ValidationException(message);
          } else if (statusCode >= 500) {
            return ServerException(message, statusCode);
          }
        }
        return ServerException(message, statusCode);
      
      case DioExceptionType.cancel:
        return const NetworkException('Request cancelled');
      
      case DioExceptionType.connectionError:
        return const NetworkException('No internet connection');
      
      case DioExceptionType.badCertificate:
        return const NetworkException('Certificate error');
      
      case DioExceptionType.unknown:
      default:
        return NetworkException(error.message ?? 'Unknown network error');
    }
  }
}