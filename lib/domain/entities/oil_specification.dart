class OilSpecification {
  final String id;
  final String brand;
  final String model;
  final int yearFrom;
  final int yearTo;
  final String engineType;
  final String? engineDisplacement;
  final String oilType;
  final String? oilBrandRecommendation;
  final double oilCapacityWithFilter;
  final double oilCapacityWithoutFilter;
  final String oilCapacityUnit;
  final String? filterType;
  final String? drainPlugTorque;
  final int? oilChangeIntervalKm;
  final int? oilChangeIntervalMonths;
  final bool isSynthetic;
  final String? viscosityGrade;
  final String? apiCertification;
  final String? specialNotes;
  final String sourceType;
  final bool isGulfMarket;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const OilSpecification({
    required this.id,
    required this.brand,
    required this.model,
    required this.yearFrom,
    required this.yearTo,
    required this.engineType,
    this.engineDisplacement,
    required this.oilType,
    this.oilBrandRecommendation,
    required this.oilCapacityWithFilter,
    required this.oilCapacityWithoutFilter,
    this.oilCapacityUnit = 'liter',
    this.filterType,
    this.drainPlugTorque,
    this.oilChangeIntervalKm,
    this.oilChangeIntervalMonths,
    this.isSynthetic = true,
    this.viscosityGrade,
    this.apiCertification,
    this.specialNotes,
    this.sourceType = 'manual',
    this.isGulfMarket = false,
    required this.createdAt,
    required this.updatedAt,
  });
  
  bool isCompatibleWithYear(int year) {
    return year >= yearFrom && year <= yearTo;
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OilSpecification &&
          runtimeType == other.runtimeType &&
          id == other.id;
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'OilSpecification{id: $id, brand: $brand, model: $model, '
           'yearFrom: $yearFrom, yearTo: $yearTo, engineType: $engineType, '
           'oilType: $oilType, oilCapacityWithFilter: $oilCapacityWithFilter}';
  }
}