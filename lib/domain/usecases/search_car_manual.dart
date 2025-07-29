import '../entities/car_info.dart';
import '../repositories/car_repository.dart';
import '../../core/errors/failures.dart';
import 'decode_vin.dart';

class SearchCarManual {
  final CarRepository repository;
  
  const SearchCarManual(this.repository);
  
  Future<Result<List<CarInfo>>> call(SearchCarParams params) async {
    try {
      // Validate that at least one parameter is provided
      if ((params.brand?.isEmpty ?? true) && 
          (params.model?.isEmpty ?? true) && 
          params.year == null) {
        return Result.failure(const ValidationFailure('At least one search parameter must be provided'));
      }
      
      // Validate year if provided
      if (params.year != null && 
          (params.year! < 1900 || params.year! > DateTime.now().year + 2)) {
        return Result.failure(const ValidationFailure('Invalid year'));
      }
      
      final cars = await repository.searchCars(
        brand: params.brand,
        model: params.model,
        year: params.year,
      );
      
      return Result.success(cars);
    } catch (e) {
      if (e is ValidationFailure) {
        return Result.failure(e);
      } else if (e is NetworkFailure) {
        return Result.failure(e);
      } else if (e is DatabaseFailure) {
        return Result.failure(e);
      } else {
        return Result.failure(Failure('Failed to search cars: ${e.toString()}'));
      }
    }
  }
  
  /// Get suggested brands
  Future<Result<List<String>>> getSuggestedBrands() async {
    try {
      final brands = await repository.getSuggestedBrands();
      return Result.success(brands);
    } catch (e) {
      return Result.failure(Failure('Failed to get suggested brands: ${e.toString()}'));
    }
  }
  
  /// Get suggested models for a brand
  Future<Result<List<String>>> getSuggestedModels(String brand) async {
    try {
      if (brand.isEmpty) {
        return Result.failure(const ValidationFailure('Brand cannot be empty'));
      }
      
      final models = await repository.getSuggestedModels(brand);
      return Result.success(models);
    } catch (e) {
      return Result.failure(Failure('Failed to get suggested models: ${e.toString()}'));
    }
  }
  
  /// Get suggested years for a brand and model
  Future<Result<List<int>>> getSuggestedYears(String brand, String model) async {
    try {
      if (brand.isEmpty || model.isEmpty) {
        return Result.failure(const ValidationFailure('Brand and model cannot be empty'));
      }
      
      final years = await repository.getSuggestedYears(brand, model);
      return Result.success(years);
    } catch (e) {
      return Result.failure(Failure('Failed to get suggested years: ${e.toString()}'));
    }
  }
}

class SearchCarParams {
  final String? brand;
  final String? model;
  final int? year;
  
  const SearchCarParams({
    this.brand,
    this.model,
    this.year,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchCarParams &&
          runtimeType == other.runtimeType &&
          brand == other.brand &&
          model == other.model &&
          year == other.year;
  
  @override
  int get hashCode =>
      brand.hashCode ^
      model.hashCode ^
      year.hashCode;
  
  @override
  String toString() {
    return 'SearchCarParams{brand: $brand, model: $model, year: $year}';
  }
}