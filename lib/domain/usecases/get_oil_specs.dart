import '../entities/oil_specification.dart';
import '../repositories/car_repository.dart';
import '../../core/errors/failures.dart';
import 'decode_vin.dart';

class GetOilSpecs {
  final CarRepository repository;
  
  const GetOilSpecs(this.repository);
  
  Future<Result<List<OilSpecification>>> call(OilSpecsParams params) async {
    try {
      // Validate parameters
      if (params.brand.isEmpty) {
        return Result.failure(const ValidationFailure('Brand cannot be empty'));
      }
      
      if (params.model.isEmpty) {
        return Result.failure(const ValidationFailure('Model cannot be empty'));
      }
      
      if (params.year < 1900 || params.year > DateTime.now().year + 2) {
        return Result.failure(const ValidationFailure('Invalid year'));
      }
      
      final oilSpecs = await repository.getOilSpecifications(
        brand: params.brand,
        model: params.model,
        year: params.year,
        engineType: params.engineType,
      );
      
      if (oilSpecs.isEmpty) {
        return Result.failure(const NotFoundFailure('No oil specifications found for this vehicle'));
      }
      
      return Result.success(oilSpecs);
    } catch (e) {
      if (e is ValidationFailure) {
        return Result.failure(e);
      } else if (e is NetworkFailure) {
        return Result.failure(e);
      } else if (e is DatabaseFailure) {
        return Result.failure(e);
      } else if (e is NotFoundFailure) {
        return Result.failure(e);
      } else {
        return Result.failure(Failure('Failed to get oil specifications: ${e.toString()}'));
      }
    }
  }
}

class OilSpecsParams {
  final String brand;
  final String model;
  final int year;
  final String? engineType;
  
  const OilSpecsParams({
    required this.brand,
    required this.model,
    required this.year,
    this.engineType,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OilSpecsParams &&
          runtimeType == other.runtimeType &&
          brand == other.brand &&
          model == other.model &&
          year == other.year &&
          engineType == other.engineType;
  
  @override
  int get hashCode =>
      brand.hashCode ^
      model.hashCode ^
      year.hashCode ^
      engineType.hashCode;
  
  @override
  String toString() {
    return 'OilSpecsParams{brand: $brand, model: $model, year: $year, engineType: $engineType}';
  }
}