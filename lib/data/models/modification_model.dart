import '../../domain/entities/car_modification.dart';

class ModificationModel extends CarModification {
  const ModificationModel({
    required super.id,
    required super.carOilSpecId,
    required super.modificationType,
    super.modifiedOilType,
    super.modifiedCapacityWithFilter,
    super.modifiedCapacityWithoutFilter,
    super.modificationNotes,
    super.performanceImpact,
    required super.createdAt,
  });
  
  factory ModificationModel.fromJson(Map<String, dynamic> json) {
    return ModificationModel(
      id: json['id'] as String,
      carOilSpecId: json['car_oil_spec_id'] as String,
      modificationType: json['modification_type'] as String,
      modifiedOilType: json['modified_oil_type'] as String?,
      modifiedCapacityWithFilter: (json['modified_capacity_with_filter'] as num?)?.toDouble(),
      modifiedCapacityWithoutFilter: (json['modified_capacity_without_filter'] as num?)?.toDouble(),
      modificationNotes: json['modification_notes'] as String?,
      performanceImpact: json['performance_impact'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'car_oil_spec_id': carOilSpecId,
      'modification_type': modificationType,
      'modified_oil_type': modifiedOilType,
      'modified_capacity_with_filter': modifiedCapacityWithFilter,
      'modified_capacity_without_filter': modifiedCapacityWithoutFilter,
      'modification_notes': modificationNotes,
      'performance_impact': performanceImpact,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  CarModification toEntity() {
    return CarModification(
      id: id,
      carOilSpecId: carOilSpecId,
      modificationType: modificationType,
      modifiedOilType: modifiedOilType,
      modifiedCapacityWithFilter: modifiedCapacityWithFilter,
      modifiedCapacityWithoutFilter: modifiedCapacityWithoutFilter,
      modificationNotes: modificationNotes,
      performanceImpact: performanceImpact,
      createdAt: createdAt,
    );
  }
  
  factory ModificationModel.fromEntity(CarModification entity) {
    return ModificationModel(
      id: entity.id,
      carOilSpecId: entity.carOilSpecId,
      modificationType: entity.modificationType,
      modifiedOilType: entity.modifiedOilType,
      modifiedCapacityWithFilter: entity.modifiedCapacityWithFilter,
      modifiedCapacityWithoutFilter: entity.modifiedCapacityWithoutFilter,
      modificationNotes: entity.modificationNotes,
      performanceImpact: entity.performanceImpact,
      createdAt: entity.createdAt,
    );
  }
}