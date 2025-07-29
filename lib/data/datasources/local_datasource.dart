import 'dart:convert';
import 'package:hive/hive.dart';
import '../../core/errors/exceptions.dart';
import '../models/car_info_model.dart';
import '../models/oil_spec_model.dart';

abstract class LocalDataSource {
  Future<void> cacheCarInfo(String vin, CarInfoModel carInfo);
  Future<CarInfoModel?> getCachedCarInfo(String vin);
  
  Future<void> cacheOilSpecs(String key, List<OilSpecModel> oilSpecs);
  Future<List<OilSpecModel>?> getCachedOilSpecs(String key);
  
  Future<void> cacheSearchSuggestions(String type, List<String> suggestions);
  Future<List<String>?> getCachedSearchSuggestions(String type);
  
  Future<void> clearCache();
  Future<void> clearExpiredCache();
}

class LocalDataSourceImpl implements LocalDataSource {
  static const String carInfoBoxName = 'car_info_cache';
  static const String oilSpecsBoxName = 'oil_specs_cache';
  static const String suggestionsBoxName = 'suggestions_cache';
  static const String metadataBoxName = 'cache_metadata';
  
  static const Duration cacheExpiry = Duration(days: 7);
  
  late Box<String> _carInfoBox;
  late Box<String> _oilSpecsBox;
  late Box<String> _suggestionsBox;
  late Box<String> _metadataBox;
  
  Future<void> initialize() async {
    _carInfoBox = await Hive.openBox<String>(carInfoBoxName);
    _oilSpecsBox = await Hive.openBox<String>(oilSpecsBoxName);
    _suggestionsBox = await Hive.openBox<String>(suggestionsBoxName);
    _metadataBox = await Hive.openBox<String>(metadataBoxName);
  }
  
  @override
  Future<void> cacheCarInfo(String vin, CarInfoModel carInfo) async {
    try {
      final jsonString = jsonEncode(carInfo.toJson());
      await _carInfoBox.put(vin, jsonString);
      
      // Store metadata for expiry tracking
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await _metadataBox.put('car_info_$vin', timestamp.toString());
    } catch (e) {
      throw CacheException('Failed to cache car info: ${e.toString()}');
    }
  }
  
  @override
  Future<CarInfoModel?> getCachedCarInfo(String vin) async {
    try {
      final jsonString = _carInfoBox.get(vin);
      if (jsonString == null) return null;
      
      // Check if cache is expired
      final timestampString = _metadataBox.get('car_info_$vin');
      if (timestampString != null) {
        final timestamp = int.tryParse(timestampString);
        if (timestamp != null) {
          final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
          if (DateTime.now().difference(cacheTime) > cacheExpiry) {
            // Cache expired, remove it
            await _carInfoBox.delete(vin);
            await _metadataBox.delete('car_info_$vin');
            return null;
          }
        }
      }
      
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return CarInfoModel.fromJson(json);
    } catch (e) {
      throw CacheException('Failed to get cached car info: ${e.toString()}');
    }
  }
  
  @override
  Future<void> cacheOilSpecs(String key, List<OilSpecModel> oilSpecs) async {
    try {
      final jsonList = oilSpecs.map((spec) => spec.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await _oilSpecsBox.put(key, jsonString);
      
      // Store metadata for expiry tracking
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await _metadataBox.put('oil_specs_$key', timestamp.toString());
    } catch (e) {
      throw CacheException('Failed to cache oil specs: ${e.toString()}');
    }
  }
  
  @override
  Future<List<OilSpecModel>?> getCachedOilSpecs(String key) async {
    try {
      final jsonString = _oilSpecsBox.get(key);
      if (jsonString == null) return null;
      
      // Check if cache is expired
      final timestampString = _metadataBox.get('oil_specs_$key');
      if (timestampString != null) {
        final timestamp = int.tryParse(timestampString);
        if (timestamp != null) {
          final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
          if (DateTime.now().difference(cacheTime) > cacheExpiry) {
            // Cache expired, remove it
            await _oilSpecsBox.delete(key);
            await _metadataBox.delete('oil_specs_$key');
            return null;
          }
        }
      }
      
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => OilSpecModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException('Failed to get cached oil specs: ${e.toString()}');
    }
  }
  
  @override
  Future<void> cacheSearchSuggestions(String type, List<String> suggestions) async {
    try {
      final jsonString = jsonEncode(suggestions);
      await _suggestionsBox.put(type, jsonString);
      
      // Store metadata for expiry tracking
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await _metadataBox.put('suggestions_$type', timestamp.toString());
    } catch (e) {
      throw CacheException('Failed to cache search suggestions: ${e.toString()}');
    }
  }
  
  @override
  Future<List<String>?> getCachedSearchSuggestions(String type) async {
    try {
      final jsonString = _suggestionsBox.get(type);
      if (jsonString == null) return null;
      
      // Check if cache is expired
      final timestampString = _metadataBox.get('suggestions_$type');
      if (timestampString != null) {
        final timestamp = int.tryParse(timestampString);
        if (timestamp != null) {
          final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
          if (DateTime.now().difference(cacheTime) > cacheExpiry) {
            // Cache expired, remove it
            await _suggestionsBox.delete(type);
            await _metadataBox.delete('suggestions_$type');
            return null;
          }
        }
      }
      
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.cast<String>();
    } catch (e) {
      throw CacheException('Failed to get cached search suggestions: ${e.toString()}');
    }
  }
  
  @override
  Future<void> clearCache() async {
    try {
      await _carInfoBox.clear();
      await _oilSpecsBox.clear();
      await _suggestionsBox.clear();
      await _metadataBox.clear();
    } catch (e) {
      throw CacheException('Failed to clear cache: ${e.toString()}');
    }
  }
  
  @override
  Future<void> clearExpiredCache() async {
    try {
      final now = DateTime.now();
      
      // Clear expired car info
      final carInfoKeys = _carInfoBox.keys.toList();
      for (final key in carInfoKeys) {
        final timestampString = _metadataBox.get('car_info_$key');
        if (timestampString != null) {
          final timestamp = int.tryParse(timestampString);
          if (timestamp != null) {
            final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
            if (now.difference(cacheTime) > cacheExpiry) {
              await _carInfoBox.delete(key);
              await _metadataBox.delete('car_info_$key');
            }
          }
        }
      }
      
      // Clear expired oil specs
      final oilSpecsKeys = _oilSpecsBox.keys.toList();
      for (final key in oilSpecsKeys) {
        final timestampString = _metadataBox.get('oil_specs_$key');
        if (timestampString != null) {
          final timestamp = int.tryParse(timestampString);
          if (timestamp != null) {
            final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
            if (now.difference(cacheTime) > cacheExpiry) {
              await _oilSpecsBox.delete(key);
              await _metadataBox.delete('oil_specs_$key');
            }
          }
        }
      }
      
      // Clear expired suggestions
      final suggestionsKeys = _suggestionsBox.keys.toList();
      for (final key in suggestionsKeys) {
        final timestampString = _metadataBox.get('suggestions_$key');
        if (timestampString != null) {
          final timestamp = int.tryParse(timestampString);
          if (timestamp != null) {
            final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
            if (now.difference(cacheTime) > cacheExpiry) {
              await _suggestionsBox.delete(key);
              await _metadataBox.delete('suggestions_$key');
            }
          }
        }
      }
    } catch (e) {
      throw CacheException('Failed to clear expired cache: ${e.toString()}');
    }
  }
}