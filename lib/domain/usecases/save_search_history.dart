import '../repositories/car_repository.dart';
import '../../core/errors/failures.dart';
import 'decode_vin.dart';

class SaveSearchHistory {
  final CarRepository repository;
  
  const SaveSearchHistory(this.repository);
  
  Future<Result<void>> call(SearchHistoryParams params) async {
    try {
      await repository.saveSearchHistory(
        deviceId: params.deviceId,
        vinNumber: params.vinNumber,
        brand: params.brand,
        model: params.model,
        year: params.year,
        searchMethod: params.searchMethod,
        resultFound: params.resultFound,
      );
      
      return Result.success(null);
    } catch (e) {
      if (e is DatabaseFailure) {
        return Result.failure(e);
      } else {
        return Result.failure(Failure('Failed to save search history: ${e.toString()}'));
      }
    }
  }
  
  /// Get search history
  Future<Result<List<Map<String, dynamic>>>> getSearchHistory(String? deviceId) async {
    try {
      final history = await repository.getSearchHistory(deviceId);
      return Result.success(history);
    } catch (e) {
      return Result.failure(Failure('Failed to get search history: ${e.toString()}'));
    }
  }
  
  /// Clear search history
  Future<Result<void>> clearSearchHistory(String? deviceId) async {
    try {
      await repository.clearSearchHistory(deviceId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(Failure('Failed to clear search history: ${e.toString()}'));
    }
  }
}

class SearchHistoryParams {
  final String? deviceId;
  final String? vinNumber;
  final String? brand;
  final String? model;
  final int? year;
  final String searchMethod;
  final bool resultFound;
  
  const SearchHistoryParams({
    this.deviceId,
    this.vinNumber,
    this.brand,
    this.model,
    this.year,
    required this.searchMethod,
    required this.resultFound,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchHistoryParams &&
          runtimeType == other.runtimeType &&
          deviceId == other.deviceId &&
          vinNumber == other.vinNumber &&
          brand == other.brand &&
          model == other.model &&
          year == other.year &&
          searchMethod == other.searchMethod &&
          resultFound == other.resultFound;
  
  @override
  int get hashCode =>
      deviceId.hashCode ^
      vinNumber.hashCode ^
      brand.hashCode ^
      model.hashCode ^
      year.hashCode ^
      searchMethod.hashCode ^
      resultFound.hashCode;
  
  @override
  String toString() {
    return 'SearchHistoryParams{deviceId: $deviceId, vinNumber: $vinNumber, '
           'brand: $brand, model: $model, year: $year, searchMethod: $searchMethod, '
           'resultFound: $resultFound}';
  }
}