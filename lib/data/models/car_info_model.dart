import '../../domain/entities/car_info.dart';

class CarInfoModel extends CarInfo {
  const CarInfoModel({
    super.vin,
    required super.brand,
    required super.model,
    required super.year,
    super.engineType,
    super.engineDisplacement,
    super.bodyStyle,
    super.fuelType,
  });
  
  factory CarInfoModel.fromJson(Map<String, dynamic> json) {
    return CarInfoModel(
      vin: json['vin'] as String?,
      brand: json['brand'] as String? ?? json['Make'] as String? ?? '',
      model: json['model'] as String? ?? json['Model'] as String? ?? '',
      year: _parseYear(json['year'] ?? json['ModelYear'] ?? json['Model Year']),
      engineType: json['engine_type'] as String? ?? json['EngineModel'] as String?,
      engineDisplacement: json['engine_displacement'] as String? ?? json['DisplacementL'] as String?,
      bodyStyle: json['body_style'] as String? ?? json['BodyClass'] as String?,
      fuelType: json['fuel_type'] as String? ?? json['FuelTypePrimary'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'vin': vin,
      'brand': brand,
      'model': model,
      'year': year,
      'engine_type': engineType,
      'engine_displacement': engineDisplacement,
      'body_style': bodyStyle,
      'fuel_type': fuelType,
    };
  }
  
  CarInfo toEntity() {
    return CarInfo(
      vin: vin,
      brand: brand,
      model: model,
      year: year,
      engineType: engineType,
      engineDisplacement: engineDisplacement,
      bodyStyle: bodyStyle,
      fuelType: fuelType,
    );
  }
  
  factory CarInfoModel.fromEntity(CarInfo entity) {
    return CarInfoModel(
      vin: entity.vin,
      brand: entity.brand,
      model: entity.model,
      year: entity.year,
      engineType: entity.engineType,
      engineDisplacement: entity.engineDisplacement,
      bodyStyle: entity.bodyStyle,
      fuelType: entity.fuelType,
    );
  }
  
  static int _parseYear(dynamic yearValue) {
    if (yearValue == null) return DateTime.now().year;
    
    if (yearValue is int) return yearValue;
    if (yearValue is String) {
      final parsed = int.tryParse(yearValue);
      if (parsed != null) return parsed;
    }
    
    return DateTime.now().year;
  }
}

// NHTSA API Response Models
class NhtsaVinResponse {
  final String message;
  final List<VinResult> results;
  final int count;
  
  const NhtsaVinResponse({
    required this.message,
    required this.results,
    required this.count,
  });
  
  factory NhtsaVinResponse.fromJson(Map<String, dynamic> json) {
    return NhtsaVinResponse(
      message: json['Message'] as String? ?? '',
      results: (json['Results'] as List<dynamic>?)
          ?.map((e) => VinResult.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      count: json['Count'] as int? ?? 0,
    );
  }
}

class VinResult {
  final String? variable;
  final String? value;
  final String? valueId;
  
  const VinResult({
    this.variable,
    this.value,
    this.valueId,
  });
  
  factory VinResult.fromJson(Map<String, dynamic> json) {
    return VinResult(
      variable: json['Variable'] as String?,
      value: json['Value'] as String?,
      valueId: json['ValueId'] as String?,
    );
  }
}