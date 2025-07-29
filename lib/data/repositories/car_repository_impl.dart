import '../../domain/entities/car_info.dart';
import '../../domain/entities/oil_specification.dart';
import '../../domain/entities/car_modification.dart';
import '../../domain/repositories/car_repository.dart';
import '../../core/network/network_info.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../datasources/vin_api_datasource.dart';
import '../datasources/supabase_datasource.dart';
import '../datasources/local_datasource.dart';

class CarRepositoryImpl implements CarRepository {
  final VinApiDataSource vinApiDataSource;
  final SupabaseDataSource supabaseDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  
  const CarRepositoryImpl({
    required this.vinApiDataSource,
    required this.supabaseDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<CarInfo> decodeVin(String vin) async {
    try {
      // First try to get from cache
      final cachedCarInfo = await localDataSource.getCachedCarInfo(vin);
      if (cachedCarInfo != null) {
        return cachedCarInfo.toEntity();
      }
      
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        throw const NetworkFailure('No internet connection');
      }
      
      // Decode VIN using API
      final carInfoModel = await vinApiDataSource.decodeVin(vin);
      
      // Cache the result
      await localDataSource.cacheCarInfo(vin, carInfoModel);
      
      return carInfoModel.toEntity();
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message, e.statusCode);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, e.statusCode);
    } on NotFoundException catch (e) {
      throw NotFoundFailure(e.message);
    } on ValidationException catch (e) {
      throw ValidationFailure(e.message);
    } on VinDecodingException catch (e) {
      throw VinDecodingFailure(e.message);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw VinDecodingFailure('Unexpected error during VIN decoding: ${e.toString()}');
    }
  }
  
  @override
  Future<List<OilSpecification>> getOilSpecifications({
    required String brand,
    required String model,
    required int year,
    String? engineType,
  }) async {
    try {
      // Create cache key
      final cacheKey = '${brand.toLowerCase()}_${model.toLowerCase()}_$year${engineType != null ? '_${engineType.toLowerCase()}' : ''}';
      
      // First try to get from cache
      final cachedOilSpecs = await localDataSource.getCachedOilSpecs(cacheKey);
      if (cachedOilSpecs != null && cachedOilSpecs.isNotEmpty) {
        return cachedOilSpecs.map((model) => model.toEntity()).toList();
      }
      
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        throw const NetworkFailure('No internet connection');
      }
      
      // Get from Supabase
      final oilSpecModels = await supabaseDataSource.getOilSpecifications(
        brand: brand,
        model: model,
        year: year,
        engineType: engineType,
      );
      
      // Cache the result
      if (oilSpecModels.isNotEmpty) {
        await localDataSource.cacheOilSpecs(cacheKey, oilSpecModels);
      }
      
      return oilSpecModels.map((model) => model.toEntity()).toList();
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message, e.code);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message, e.statusCode);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw DatabaseFailure('Unexpected error getting oil specifications: ${e.toString()}');
    }
  }
  
  @override
  Future<OilSpecification?> getOilSpecificationById(String id) async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        throw const NetworkFailure('No internet connection');
      }
      
      final oilSpecModel = await supabaseDataSource.getOilSpecificationById(id);
      return oilSpecModel?.toEntity();
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message, e.code);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message, e.statusCode);
    } catch (e) {
      throw DatabaseFailure('Unexpected error getting oil specification: ${e.toString()}');
    }
  }
  
  @override
  Future<List<CarInfo>> searchCars({
    String? brand,
    String? model,
    int? year,
  }) async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        throw const NetworkFailure('No internet connection');
      }
      
      final carModels = await supabaseDataSource.searchCars(
        brand: brand,
        model: model,
        year: year,
      );
      
      return carModels.map((model) => model.toEntity()).toList();
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message, e.code);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message, e.statusCode);
    } catch (e) {
      throw DatabaseFailure('Unexpected error searching cars: ${e.toString()}');
    }
  }
  
  @override
  Future<List<CarModification>> getCarModifications(String oilSpecId) async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        throw const NetworkFailure('No internet connection');
      }
      
      final modificationModels = await supabaseDataSource.getCarModifications(oilSpecId);
      return modificationModels.map((model) => model.toEntity()).toList();
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message, e.code);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message, e.statusCode);
    } catch (e) {
      throw DatabaseFailure('Unexpected error getting car modifications: ${e.toString()}');
    }
  }
  
  @override
  Future<void> saveSearchHistory({
    required String? deviceId,
    String? vinNumber,
    String? brand,
    String? model,
    int? year,
    required String searchMethod,
    required bool resultFound,
  }) async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        // If no internet, skip saving search history (it's not critical)
        return;
      }
      
      await supabaseDataSource.saveSearchHistory(
        deviceId: deviceId,
        vinNumber: vinNumber,
        brand: brand,
        model: model,
        year: year,
        searchMethod: searchMethod,
        resultFound: resultFound,
      );
    } on DatabaseException catch (e) {
      // Don't throw error for search history failures
      print('Failed to save search history: ${e.message}');
    } catch (e) {
      // Don't throw error for search history failures
      print('Unexpected error saving search history: ${e.toString()}');
    }
  }
  
  @override
  Future<List<Map<String, dynamic>>> getSearchHistory(String? deviceId) async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        throw const NetworkFailure('No internet connection');
      }
      
      return await supabaseDataSource.getSearchHistory(deviceId);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message, e.code);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message, e.statusCode);
    } catch (e) {
      throw DatabaseFailure('Unexpected error getting search history: ${e.toString()}');
    }
  }
  
  @override
  Future<void> clearSearchHistory(String? deviceId) async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        throw const NetworkFailure('No internet connection');
      }
      
      await supabaseDataSource.clearSearchHistory(deviceId);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message, e.code);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message, e.statusCode);
    } catch (e) {
      throw DatabaseFailure('Unexpected error clearing search history: ${e.toString()}');
    }
  }
  
  @override
  Future<List<String>> getSuggestedBrands() async {
    try {
      // First try to get from cache
      final cachedBrands = await localDataSource.getCachedSearchSuggestions('brands');
      if (cachedBrands != null && cachedBrands.isNotEmpty) {
        return cachedBrands;
      }
      
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        throw const NetworkFailure('No internet connection');
      }
      
      final brands = await supabaseDataSource.getSuggestedBrands();
      
      // Cache the result
      if (brands.isNotEmpty) {
        await localDataSource.cacheSearchSuggestions('brands', brands);
      }
      
      return brands;
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message, e.code);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message, e.statusCode);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw DatabaseFailure('Unexpected error getting suggested brands: ${e.toString()}');
    }
  }
  
  @override
  Future<List<String>> getSuggestedModels(String brand) async {
    try {
      // Create cache key
      final cacheKey = 'models_${brand.toLowerCase()}';
      
      // First try to get from cache
      final cachedModels = await localDataSource.getCachedSearchSuggestions(cacheKey);
      if (cachedModels != null && cachedModels.isNotEmpty) {
        return cachedModels;
      }
      
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        throw const NetworkFailure('No internet connection');
      }
      
      final models = await supabaseDataSource.getSuggestedModels(brand);
      
      // Cache the result
      if (models.isNotEmpty) {
        await localDataSource.cacheSearchSuggestions(cacheKey, models);
      }
      
      return models;
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message, e.code);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message, e.statusCode);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw DatabaseFailure('Unexpected error getting suggested models: ${e.toString()}');
    }
  }
  
  @override
  Future<List<int>> getSuggestedYears(String brand, String model) async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        throw const NetworkFailure('No internet connection');
      }
      
      return await supabaseDataSource.getSuggestedYears(brand, model);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message, e.code);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message, e.statusCode);
    } catch (e) {
      throw DatabaseFailure('Unexpected error getting suggested years: ${e.toString()}');
    }
  }
}