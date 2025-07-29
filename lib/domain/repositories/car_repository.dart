import '../entities/car_info.dart';
import '../entities/oil_specification.dart';
import '../entities/car_modification.dart';

abstract class CarRepository {
  /// Decode VIN and get car information
  Future<CarInfo> decodeVin(String vin);
  
  /// Search oil specifications by car details
  Future<List<OilSpecification>> getOilSpecifications({
    required String brand,
    required String model,
    required int year,
    String? engineType,
  });
  
  /// Get oil specification by ID
  Future<OilSpecification?> getOilSpecificationById(String id);
  
  /// Search cars manually by partial information
  Future<List<CarInfo>> searchCars({
    String? brand,
    String? model,
    int? year,
  });
  
  /// Get car modifications for a specific oil specification
  Future<List<CarModification>> getCarModifications(String oilSpecId);
  
  /// Save search to history
  Future<void> saveSearchHistory({
    required String? deviceId,
    String? vinNumber,
    String? brand,
    String? model,
    int? year,
    required String searchMethod,
    required bool resultFound,
  });
  
  /// Get search history
  Future<List<Map<String, dynamic>>> getSearchHistory(String? deviceId);
  
  /// Clear search history
  Future<void> clearSearchHistory(String? deviceId);
  
  /// Get suggested brands
  Future<List<String>> getSuggestedBrands();
  
  /// Get suggested models for a brand
  Future<List<String>> getSuggestedModels(String brand);
  
  /// Get suggested years for a brand and model
  Future<List<int>> getSuggestedYears(String brand, String model);
}