class ApiEndpoints {
  // NHTSA Vehicle API for VIN decoding
  static const String nhtsa = 'https://vpic.nhtsa.dot.gov/api/vehicles';
  static const String vinDecode = '$nhtsa/DecodeVin';
  
  // Alternative VIN Decoder APIs
  static const String vinAudit = 'https://api.vinaudit.com/v2';
  static const String autoCheck = 'https://api.autocheck.com/v1';
  
  // Timeout configurations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Response format
  static const String responseFormat = 'json';
}