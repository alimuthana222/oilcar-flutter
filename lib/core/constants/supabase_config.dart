import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Supabase credentials - these should be replaced with actual values
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // Table names
  static const String carOilSpecsTable = 'car_oil_specs';
  static const String carModificationsTable = 'car_modifications';
  static const String searchHistoryTable = 'search_history';
  
  // Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: false,
    );
  }
  
  // Get Supabase client
  static SupabaseClient get client => Supabase.instance.client;
}

// Database column names for car_oil_specs table
class CarOilSpecsColumns {
  static const String id = 'id';
  static const String brand = 'brand';
  static const String model = 'model';
  static const String yearFrom = 'year_from';
  static const String yearTo = 'year_to';
  static const String engineType = 'engine_type';
  static const String engineDisplacement = 'engine_displacement';
  static const String oilType = 'oil_type';
  static const String oilBrandRecommendation = 'oil_brand_recommendation';
  static const String oilCapacityWithFilter = 'oil_capacity_with_filter';
  static const String oilCapacityWithoutFilter = 'oil_capacity_without_filter';
  static const String oilCapacityUnit = 'oil_capacity_unit';
  static const String filterType = 'filter_type';
  static const String drainPlugTorque = 'drain_plug_torque';
  static const String oilChangeIntervalKm = 'oil_change_interval_km';
  static const String oilChangeIntervalMonths = 'oil_change_interval_months';
  static const String isSynthetic = 'is_synthetic';
  static const String viscosityGrade = 'viscosity_grade';
  static const String apiCertification = 'api_certification';
  static const String specialNotes = 'special_notes';
  static const String sourceType = 'source_type';
  static const String isGulfMarket = 'is_gulf_market';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

// Database column names for search_history table
class SearchHistoryColumns {
  static const String id = 'id';
  static const String userDeviceId = 'user_device_id';
  static const String vinNumber = 'vin_number';
  static const String brand = 'brand';
  static const String model = 'model';
  static const String year = 'year';
  static const String searchMethod = 'search_method';
  static const String resultFound = 'result_found';
  static const String createdAt = 'created_at';
}

// Search methods enum
class SearchMethods {
  static const String vinScan = 'vin_scan';
  static const String vinManual = 'vin_manual';
  static const String manualInput = 'manual_input';
}