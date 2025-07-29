class VinValidator {
  // VIN must be exactly 17 characters
  static const int vinLength = 17;
  
  // Characters not allowed in VIN
  static const List<String> forbiddenChars = ['I', 'O', 'Q'];
  
  // VIN regex pattern
  static final RegExp vinPattern = RegExp(r'^[A-HJ-NPR-Z0-9]{17}$');
  
  /// Validates VIN format
  static bool isValidFormat(String vin) {
    if (vin.isEmpty) return false;
    
    // Remove spaces and convert to uppercase
    vin = vin.replaceAll(' ', '').toUpperCase();
    
    // Check length
    if (vin.length != vinLength) return false;
    
    // Check pattern
    if (!vinPattern.hasMatch(vin)) return false;
    
    // Check for forbidden characters
    for (String char in forbiddenChars) {
      if (vin.contains(char)) return false;
    }
    
    return true;
  }
  
  /// Validates VIN with check digit
  static bool isValidVin(String vin) {
    if (!isValidFormat(vin)) return false;
    
    vin = vin.replaceAll(' ', '').toUpperCase();
    
    // Calculate check digit
    int calculatedCheckDigit = _calculateCheckDigit(vin);
    String checkDigitChar = vin[8];
    
    // Convert check digit character to number
    int actualCheckDigit;
    if (checkDigitChar == 'X') {
      actualCheckDigit = 10;
    } else if (RegExp(r'^[0-9]$').hasMatch(checkDigitChar)) {
      actualCheckDigit = int.parse(checkDigitChar);
    } else {
      return false;
    }
    
    return calculatedCheckDigit == actualCheckDigit;
  }
  
  /// Calculate VIN check digit
  static int _calculateCheckDigit(String vin) {
    // VIN weights for positions 1-17 (excluding position 9)
    final List<int> weights = [8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2];
    
    // Character to number mapping
    final Map<String, int> charToNum = {
      'A': 1, 'B': 2, 'C': 3, 'D': 4, 'E': 5, 'F': 6, 'G': 7, 'H': 8,
      'J': 1, 'K': 2, 'L': 3, 'M': 4, 'N': 5, 'P': 7, 'R': 9,
      'S': 2, 'T': 3, 'U': 4, 'V': 5, 'W': 6, 'X': 7, 'Y': 8, 'Z': 9,
      '0': 0, '1': 1, '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7, '8': 8, '9': 9
    };
    
    int sum = 0;
    for (int i = 0; i < vin.length; i++) {
      if (i == 8) continue; // Skip check digit position
      
      String char = vin[i];
      int value = charToNum[char] ?? 0;
      sum += value * weights[i];
    }
    
    int remainder = sum % 11;
    return remainder;
  }
  
  /// Clean VIN by removing spaces and converting to uppercase
  static String cleanVin(String vin) {
    return vin.replaceAll(' ', '').toUpperCase();
  }
  
  /// Format VIN with spaces for better readability
  static String formatVin(String vin) {
    if (vin.length != vinLength) return vin;
    
    vin = cleanVin(vin);
    
    // Format as XXX XXXX XXXX XXXX
    return '${vin.substring(0, 3)} ${vin.substring(3, 7)} ${vin.substring(7, 11)} ${vin.substring(11, 17)}';
  }
  
  /// Extract basic info from VIN
  static Map<String, String> extractBasicInfo(String vin) {
    if (!isValidFormat(vin)) {
      return {};
    }
    
    vin = cleanVin(vin);
    
    return {
      'worldManufacturerIdentifier': vin.substring(0, 3),
      'vehicleDescriptorSection': vin.substring(3, 9),
      'vehicleIdentifierSection': vin.substring(9, 17),
      'checkDigit': vin[8],
      'modelYear': _getModelYear(vin[9]),
      'plantCode': vin[10],
    };
  }
  
  /// Get model year from VIN character
  static String _getModelYear(String yearChar) {
    final Map<String, String> yearMap = {
      'A': '2010', 'B': '2011', 'C': '2012', 'D': '2013', 'E': '2014',
      'F': '2015', 'G': '2016', 'H': '2017', 'J': '2018', 'K': '2019',
      'L': '2020', 'M': '2021', 'N': '2022', 'P': '2023', 'R': '2024',
      'S': '2025', 'T': '2026', 'V': '2027', 'W': '2028', 'X': '2029',
      'Y': '2030', 'Z': '2031',
      '1': '2001', '2': '2002', '3': '2003', '4': '2004', '5': '2005',
      '6': '2006', '7': '2007', '8': '2008', '9': '2009',
    };
    
    return yearMap[yearChar] ?? 'Unknown';
  }
}