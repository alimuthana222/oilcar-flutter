import 'package:flutter_test/flutter_test.dart';
import 'package:oilcar_flutter/core/utils/vin_validator.dart';

void main() {
  group('VIN Validator Tests', () {
    test('should validate correct VIN format', () {
      const validVin = '1HGBH41JXMN109186';
      expect(VinValidator.isValidFormat(validVin), true);
    });
    
    test('should reject invalid VIN length', () {
      const invalidVin = '1HGBH41JXMN10918';
      expect(VinValidator.isValidFormat(invalidVin), false);
    });
    
    test('should reject VIN with forbidden characters', () {
      const invalidVin = '1HGBH41JXMN10918I';
      expect(VinValidator.isValidFormat(invalidVin), false);
    });
    
    test('should clean VIN properly', () {
      const vinWithSpaces = '1HG BH4 1JXM N109 186';
      const expectedClean = '1HGBH41JXMN109186';
      expect(VinValidator.cleanVin(vinWithSpaces), expectedClean);
    });
    
    test('should format VIN with spaces', () {
      const vin = '1HGBH41JXMN109186';
      const expectedFormatted = '1HG BH41 JXMN 109186';
      expect(VinValidator.formatVin(vin), expectedFormatted);
    });
  });
}