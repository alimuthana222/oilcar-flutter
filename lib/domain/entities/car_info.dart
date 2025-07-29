class CarInfo {
  final String? vin;
  final String brand;
  final String model;
  final int year;
  final String? engineType;
  final String? engineDisplacement;
  final String? bodyStyle;
  final String? fuelType;
  
  const CarInfo({
    this.vin,
    required this.brand,
    required this.model,
    required this.year,
    this.engineType,
    this.engineDisplacement,
    this.bodyStyle,
    this.fuelType,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CarInfo &&
          runtimeType == other.runtimeType &&
          vin == other.vin &&
          brand == other.brand &&
          model == other.model &&
          year == other.year &&
          engineType == other.engineType &&
          engineDisplacement == other.engineDisplacement &&
          bodyStyle == other.bodyStyle &&
          fuelType == other.fuelType;
  
  @override
  int get hashCode =>
      vin.hashCode ^
      brand.hashCode ^
      model.hashCode ^
      year.hashCode ^
      engineType.hashCode ^
      engineDisplacement.hashCode ^
      bodyStyle.hashCode ^
      fuelType.hashCode;
  
  @override
  String toString() {
    return 'CarInfo{vin: $vin, brand: $brand, model: $model, year: $year, '
           'engineType: $engineType, engineDisplacement: $engineDisplacement, '
           'bodyStyle: $bodyStyle, fuelType: $fuelType}';
  }
}