import '../entities/car_info.dart';
import '../repositories/car_repository.dart';
import '../../core/errors/failures.dart';

class DecodeVin {
  final CarRepository repository;
  
  const DecodeVin(this.repository);
  
  Future<Result<CarInfo>> call(String vin) async {
    try {
      // Validate VIN format first
      if (vin.isEmpty) {
        return Result.failure(const ValidationFailure('VIN cannot be empty'));
      }
      
      // Clean VIN
      final cleanedVin = vin.replaceAll(' ', '').toUpperCase();
      
      if (cleanedVin.length != 17) {
        return Result.failure(const ValidationFailure('VIN must be 17 characters long'));
      }
      
      final carInfo = await repository.decodeVin(cleanedVin);
      return Result.success(carInfo);
    } catch (e) {
      if (e is ValidationFailure) {
        return Result.failure(e);
      } else if (e is NetworkFailure) {
        return Result.failure(e);
      } else if (e is NotFoundFailure) {
        return Result.failure(e);
      } else {
        return Result.failure(VinDecodingFailure('Failed to decode VIN: ${e.toString()}'));
      }
    }
  }
}

class Result<T> {
  final T? data;
  final Failure? failure;
  
  const Result._(this.data, this.failure);
  
  factory Result.success(T data) => Result._(data, null);
  factory Result.failure(Failure failure) => Result._(null, failure);
  
  bool get isSuccess => data != null;
  bool get isFailure => failure != null;
  
  T get value {
    if (data != null) return data!;
    throw Exception('Tried to get value from failed result');
  }
  
  Failure get error {
    if (failure != null) return failure!;
    throw Exception('Tried to get error from successful result');
  }
}