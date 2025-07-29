import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/car_info_model.dart';

abstract class VinApiDataSource {
  Future<CarInfoModel> decodeVin(String vin);
}

class VinApiDataSourceImpl implements VinApiDataSource {
  final ApiClient apiClient;
  
  const VinApiDataSourceImpl(this.apiClient);
  
  @override
  Future<CarInfoModel> decodeVin(String vin) async {
    try {
      // First try NHTSA API
      final response = await apiClient.get(
        '${ApiEndpoints.vinDecode}/$vin',
        queryParameters: {
          'format': ApiEndpoints.responseFormat,
        },
      );
      
      if (response.statusCode == 200) {
        final nhtsaResponse = NhtsaVinResponse.fromJson(response.data);
        
        if (nhtsaResponse.results.isNotEmpty) {
          return _parseNhtsaResponse(vin, nhtsaResponse.results);
        } else {
          throw const NotFoundException('VIN not found in NHTSA database');
        }
      } else {
        throw ServerException(
          'NHTSA API returned status code: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is NotFoundException || e is ServerException || e is NetworkException) {
        rethrow;
      }
      
      // If NHTSA fails, try alternative APIs or return basic info
      throw VinDecodingException('Failed to decode VIN: ${e.toString()}');
    }
  }
  
  CarInfoModel _parseNhtsaResponse(String vin, List<VinResult> results) {
    final Map<String, String> dataMap = {};
    
    // Extract relevant data from NHTSA response
    for (final result in results) {
      if (result.variable != null && result.value != null && result.value!.isNotEmpty) {
        dataMap[result.variable!] = result.value!;
      }
    }
    
    // Map NHTSA fields to our model
    final brand = dataMap['Make'] ?? '';
    final model = dataMap['Model'] ?? '';
    final yearStr = dataMap['Model Year'] ?? dataMap['ModelYear'] ?? '';
    
    int year = DateTime.now().year;
    if (yearStr.isNotEmpty) {
      year = int.tryParse(yearStr) ?? DateTime.now().year;
    }
    
    if (brand.isEmpty || model.isEmpty) {
      throw const NotFoundException('Incomplete vehicle information from NHTSA API');
    }
    
    return CarInfoModel(
      vin: vin,
      brand: brand,
      model: model,
      year: year,
      engineType: dataMap['Engine Model'] ?? dataMap['EngineModel'],
      engineDisplacement: dataMap['Displacement (L)'] ?? dataMap['DisplacementL'],
      bodyStyle: dataMap['Body Class'] ?? dataMap['BodyClass'],
      fuelType: dataMap['Fuel Type - Primary'] ?? dataMap['FuelTypePrimary'],
    );
  }
  
  /// Alternative method to try backup APIs if NHTSA fails
  Future<CarInfoModel> _tryAlternativeApis(String vin) async {
    // This could implement alternative VIN decoder APIs
    // For now, we'll extract basic info from VIN structure
    return _extractBasicInfoFromVin(vin);
  }
  
  /// Extract basic information from VIN structure
  CarInfoModel _extractBasicInfoFromVin(String vin) {
    if (vin.length != 17) {
      throw const ValidationException('Invalid VIN length');
    }
    
    // Basic VIN decoding based on VIN structure
    final wmi = vin.substring(0, 3); // World Manufacturer Identifier
    final yearChar = vin[9];
    
    // Get year from VIN
    int year = _getYearFromVinChar(yearChar);
    
    // Get basic manufacturer info from WMI
    final manufacturerInfo = _getManufacturerFromWmi(wmi);
    
    return CarInfoModel(
      vin: vin,
      brand: manufacturerInfo['brand'] ?? 'Unknown',
      model: 'Unknown Model',
      year: year,
      engineType: null,
      engineDisplacement: null,
      bodyStyle: null,
      fuelType: null,
    );
  }
  
  int _getYearFromVinChar(String yearChar) {
    const Map<String, int> yearMap = {
      'A': 2010, 'B': 2011, 'C': 2012, 'D': 2013, 'E': 2014,
      'F': 2015, 'G': 2016, 'H': 2017, 'J': 2018, 'K': 2019,
      'L': 2020, 'M': 2021, 'N': 2022, 'P': 2023, 'R': 2024,
      'S': 2025, 'T': 2026, 'V': 2027, 'W': 2028, 'X': 2029,
      'Y': 2030, 'Z': 2031,
      '1': 2001, '2': 2002, '3': 2003, '4': 2004, '5': 2005,
      '6': 2006, '7': 2007, '8': 2008, '9': 2009,
    };
    
    return yearMap[yearChar] ?? DateTime.now().year;
  }
  
  Map<String, String> _getManufacturerFromWmi(String wmi) {
    // Common WMI codes for major manufacturers
    const Map<String, Map<String, String>> wmiMap = {
      '1G1': {'brand': 'Chevrolet', 'country': 'USA'},
      '1G6': {'brand': 'Cadillac', 'country': 'USA'},
      '1FA': {'brand': 'Ford', 'country': 'USA'},
      '1FT': {'brand': 'Ford', 'country': 'USA'},
      '1GM': {'brand': 'Pontiac', 'country': 'USA'},
      '1HG': {'brand': 'Honda', 'country': 'USA'},
      '1N4': {'brand': 'Nissan', 'country': 'USA'},
      '2T1': {'brand': 'Toyota', 'country': 'USA'},
      '3VW': {'brand': 'Volkswagen', 'country': 'Mexico'},
      '4T1': {'brand': 'Toyota', 'country': 'USA'},
      '5N1': {'brand': 'Nissan', 'country': 'USA'},
      'JH4': {'brand': 'Acura', 'country': 'Japan'},
      'JHM': {'brand': 'Honda', 'country': 'Japan'},
      'JN1': {'brand': 'Nissan', 'country': 'Japan'},
      'JT3': {'brand': 'Toyota', 'country': 'Japan'},
      'KM8': {'brand': 'Hyundai', 'country': 'Korea'},
      'KNA': {'brand': 'Kia', 'country': 'Korea'},
      'WBA': {'brand': 'BMW', 'country': 'Germany'},
      'WDD': {'brand': 'Mercedes-Benz', 'country': 'Germany'},
      'WVW': {'brand': 'Volkswagen', 'country': 'Germany'},
    };
    
    return wmiMap[wmi] ?? {'brand': 'Unknown', 'country': 'Unknown'};
  }
}