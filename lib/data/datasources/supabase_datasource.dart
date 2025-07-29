import '../../core/constants/supabase_config.dart';
import '../../core/errors/exceptions.dart';
import '../models/oil_spec_model.dart';
import '../models/modification_model.dart';
import '../models/car_info_model.dart';

abstract class SupabaseDataSource {
  Future<List<OilSpecModel>> getOilSpecifications({
    required String brand,
    required String model,
    required int year,
    String? engineType,
  });
  
  Future<OilSpecModel?> getOilSpecificationById(String id);
  
  Future<List<ModificationModel>> getCarModifications(String oilSpecId);
  
  Future<List<CarInfoModel>> searchCars({
    String? brand,
    String? model,
    int? year,
  });
  
  Future<void> saveSearchHistory({
    required String? deviceId,
    String? vinNumber,
    String? brand,
    String? model,
    int? year,
    required String searchMethod,
    required bool resultFound,
  });
  
  Future<List<Map<String, dynamic>>> getSearchHistory(String? deviceId);
  
  Future<void> clearSearchHistory(String? deviceId);
  
  Future<List<String>> getSuggestedBrands();
  
  Future<List<String>> getSuggestedModels(String brand);
  
  Future<List<int>> getSuggestedYears(String brand, String model);
}

class SupabaseDataSourceImpl implements SupabaseDataSource {
  @override
  Future<List<OilSpecModel>> getOilSpecifications({
    required String brand,
    required String model,
    required int year,
    String? engineType,
  }) async {
    try {
      var query = SupabaseConfig.client
          .from(SupabaseConfig.carOilSpecsTable)
          .select()
          .ilike('brand', '%$brand%')
          .ilike('model', '%$model%')
          .lte('year_from', year)
          .gte('year_to', year);
      
      if (engineType != null && engineType.isNotEmpty) {
        query = query.ilike('engine_type', '%$engineType%');
      }
      
      final response = await query;
      
      return response
          .map((json) => OilSpecModel.fromJson(json))
          .toList();
    } catch (e) {
      throw DatabaseException('Failed to get oil specifications: ${e.toString()}');
    }
  }
  
  @override
  Future<OilSpecModel?> getOilSpecificationById(String id) async {
    try {
      final response = await SupabaseConfig.client
          .from(SupabaseConfig.carOilSpecsTable)
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) return null;
      
      return OilSpecModel.fromJson(response);
    } catch (e) {
      throw DatabaseException('Failed to get oil specification by ID: ${e.toString()}');
    }
  }
  
  @override
  Future<List<ModificationModel>> getCarModifications(String oilSpecId) async {
    try {
      final response = await SupabaseConfig.client
          .from(SupabaseConfig.carModificationsTable)
          .select()
          .eq('car_oil_spec_id', oilSpecId);
      
      return response
          .map((json) => ModificationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw DatabaseException('Failed to get car modifications: ${e.toString()}');
    }
  }
  
  @override
  Future<List<CarInfoModel>> searchCars({
    String? brand,
    String? model,
    int? year,
  }) async {
    try {
      var query = SupabaseConfig.client
          .from(SupabaseConfig.carOilSpecsTable)
          .select('brand, model, year_from, year_to');
      
      if (brand != null && brand.isNotEmpty) {
        query = query.ilike('brand', '%$brand%');
      }
      
      if (model != null && model.isNotEmpty) {
        query = query.ilike('model', '%$model%');
      }
      
      if (year != null) {
        query = query.lte('year_from', year).gte('year_to', year);
      }
      
      final response = await query.limit(50);
      
      // Convert to unique car info models
      final Set<String> seenCars = {};
      final List<CarInfoModel> cars = [];
      
      for (final item in response) {
        final brand = item['brand'] as String;
        final model = item['model'] as String;
        final yearFrom = item['year_from'] as int;
        final yearTo = item['year_to'] as int;
        
        // Create entries for each year in range
        for (int y = yearFrom; y <= yearTo; y++) {
          final carKey = '$brand-$model-$y';
          if (!seenCars.contains(carKey)) {
            seenCars.add(carKey);
            cars.add(CarInfoModel(
              brand: brand,
              model: model,
              year: y,
            ));
          }
        }
      }
      
      return cars;
    } catch (e) {
      throw DatabaseException('Failed to search cars: ${e.toString()}');
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
      await SupabaseConfig.client
          .from(SupabaseConfig.searchHistoryTable)
          .insert({
        'user_device_id': deviceId,
        'vin_number': vinNumber,
        'brand': brand,
        'model': model,
        'year': year,
        'search_method': searchMethod,
        'result_found': resultFound,
      });
    } catch (e) {
      throw DatabaseException('Failed to save search history: ${e.toString()}');
    }
  }
  
  @override
  Future<List<Map<String, dynamic>>> getSearchHistory(String? deviceId) async {
    try {
      if (deviceId == null) return [];
      
      final response = await SupabaseConfig.client
          .from(SupabaseConfig.searchHistoryTable)
          .select()
          .eq('user_device_id', deviceId)
          .order('created_at', ascending: false)
          .limit(50);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw DatabaseException('Failed to get search history: ${e.toString()}');
    }
  }
  
  @override
  Future<void> clearSearchHistory(String? deviceId) async {
    try {
      if (deviceId == null) return;
      
      await SupabaseConfig.client
          .from(SupabaseConfig.searchHistoryTable)
          .delete()
          .eq('user_device_id', deviceId);
    } catch (e) {
      throw DatabaseException('Failed to clear search history: ${e.toString()}');
    }
  }
  
  @override
  Future<List<String>> getSuggestedBrands() async {
    try {
      final response = await SupabaseConfig.client
          .from(SupabaseConfig.carOilSpecsTable)
          .select('brand')
          .order('brand');
      
      final brands = response
          .map((item) => item['brand'] as String)
          .toSet()
          .toList();
      
      brands.sort();
      return brands;
    } catch (e) {
      throw DatabaseException('Failed to get suggested brands: ${e.toString()}');
    }
  }
  
  @override
  Future<List<String>> getSuggestedModels(String brand) async {
    try {
      final response = await SupabaseConfig.client
          .from(SupabaseConfig.carOilSpecsTable)
          .select('model')
          .ilike('brand', '%$brand%')
          .order('model');
      
      final models = response
          .map((item) => item['model'] as String)
          .toSet()
          .toList();
      
      models.sort();
      return models;
    } catch (e) {
      throw DatabaseException('Failed to get suggested models: ${e.toString()}');
    }
  }
  
  @override
  Future<List<int>> getSuggestedYears(String brand, String model) async {
    try {
      final response = await SupabaseConfig.client
          .from(SupabaseConfig.carOilSpecsTable)
          .select('year_from, year_to')
          .ilike('brand', '%$brand%')
          .ilike('model', '%$model%');
      
      final Set<int> years = {};
      
      for (final item in response) {
        final yearFrom = item['year_from'] as int;
        final yearTo = item['year_to'] as int;
        
        for (int year = yearFrom; year <= yearTo; year++) {
          years.add(year);
        }
      }
      
      final yearsList = years.toList();
      yearsList.sort((a, b) => b.compareTo(a)); // Newest first
      return yearsList;
    } catch (e) {
      throw DatabaseException('Failed to get suggested years: ${e.toString()}');
    }
  }
}