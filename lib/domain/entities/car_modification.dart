class CarModification {
  final String id;
  final String carOilSpecId;
  final String modificationType;
  final String? modifiedOilType;
  final double? modifiedCapacityWithFilter;
  final double? modifiedCapacityWithoutFilter;
  final String? modificationNotes;
  final String? performanceImpact;
  final DateTime createdAt;
  
  const CarModification({
    required this.id,
    required this.carOilSpecId,
    required this.modificationType,
    this.modifiedOilType,
    this.modifiedCapacityWithFilter,
    this.modifiedCapacityWithoutFilter,
    this.modificationNotes,
    this.performanceImpact,
    required this.createdAt,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CarModification &&
          runtimeType == other.runtimeType &&
          id == other.id;
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'CarModification{id: $id, carOilSpecId: $carOilSpecId, '
           'modificationType: $modificationType, modifiedOilType: $modifiedOilType}';
  }
}

class ModificationTypes {
  static const String turboAdded = 'turbo_added';
  static const String engineSwap = 'engine_swap';
  static const String performanceTune = 'performance_tune';
  static const String superchargerAdded = 'supercharger_added';
  static const String oilCoolerAdded = 'oil_cooler_added';
  static const String highPerformanceFilter = 'high_performance_filter';
}