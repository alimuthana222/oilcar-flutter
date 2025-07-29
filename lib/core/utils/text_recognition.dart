import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';

class TextRecognitionService {
  static final TextRecognizer _textRecognizer = TextRecognizer();
  
  /// Recognize text from image file
  static Future<String> recognizeFromFile(File imageFile) async {
    try {
      final InputImage inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      return _extractVinFromText(recognizedText.text);
    } catch (e) {
      throw Exception('Failed to recognize text: $e');
    }
  }
  
  /// Recognize text from image path
  static Future<String> recognizeFromPath(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      return await recognizeFromFile(imageFile);
    } catch (e) {
      throw Exception('Failed to recognize text from path: $e');
    }
  }
  
  /// Extract VIN from recognized text
  static String _extractVinFromText(String text) {
    // Clean the text - remove spaces, newlines, and convert to uppercase
    String cleanText = text.replaceAll(RegExp(r'\s+'), '').toUpperCase();
    
    // VIN patterns to look for
    List<RegExp> vinPatterns = [
      // Standard VIN pattern: 17 alphanumeric characters
      RegExp(r'[A-HJ-NPR-Z0-9]{17}'),
      // VIN with potential OCR errors - look for 17-character sequences
      RegExp(r'[A-Z0-9]{17}'),
      // More lenient pattern for OCR errors
      RegExp(r'[A-Z0-9]{15,19}'),
    ];
    
    // Try each pattern
    for (RegExp pattern in vinPatterns) {
      RegExpMatch? match = pattern.firstMatch(cleanText);
      if (match != null) {
        String potentialVin = match.group(0) ?? '';
        
        // If exactly 17 characters, return it
        if (potentialVin.length == 17) {
          return _cleanVinForOcr(potentialVin);
        }
        
        // If longer than 17, try to extract 17-character subsequence
        if (potentialVin.length > 17) {
          for (int i = 0; i <= potentialVin.length - 17; i++) {
            String candidate = potentialVin.substring(i, i + 17);
            String cleaned = _cleanVinForOcr(candidate);
            if (_isLikelyVin(cleaned)) {
              return cleaned;
            }
          }
        }
      }
    }
    
    // If no standard pattern found, look for VIN-like sequences in the full text
    return _findVinInFullText(text);
  }
  
  /// Clean VIN for OCR errors
  static String _cleanVinForOcr(String vin) {
    // Common OCR misreadings
    Map<String, String> ocrCorrections = {
      'I': '1',  // I often read as 1
      'O': '0',  // O often read as 0
      'Q': '0',  // Q often read as 0
      'S': '5',  // S sometimes read as 5
      'Z': '2',  // Z sometimes read as 2
      'B': '8',  // B sometimes read as 8
      'G': '6',  // G sometimes read as 6
    };
    
    String cleaned = vin;
    for (String key in ocrCorrections.keys) {
      cleaned = cleaned.replaceAll(key, ocrCorrections[key]!);
    }
    
    return cleaned;
  }
  
  /// Check if a string is likely to be a VIN
  static bool _isLikelyVin(String candidate) {
    if (candidate.length != 17) return false;
    
    // Check for forbidden characters in VIN
    if (candidate.contains('I') || candidate.contains('O') || candidate.contains('Q')) {
      return false;
    }
    
    // Check if it's mostly alphanumeric
    if (!RegExp(r'^[A-HJ-NPR-Z0-9]+$').hasMatch(candidate)) {
      return false;
    }
    
    // Check for reasonable distribution of letters and numbers
    int letterCount = RegExp(r'[A-Z]').allMatches(candidate).length;
    int numberCount = RegExp(r'[0-9]').allMatches(candidate).length;
    
    // VINs typically have a mix of letters and numbers
    return letterCount >= 3 && numberCount >= 3;
  }
  
  /// Find VIN in full text using more advanced techniques
  static String _findVinInFullText(String text) {
    // Split text into lines and words
    List<String> lines = text.split('\n');
    
    for (String line in lines) {
      // Look for lines that might contain VIN
      if (_lineContainsVinKeywords(line)) {
        String cleaned = line.replaceAll(RegExp(r'[^A-Z0-9]'), '').toUpperCase();
        
        // Look for 17-character sequences in this line
        for (int i = 0; i <= cleaned.length - 17; i++) {
          String candidate = cleaned.substring(i, i + 17);
          if (_isLikelyVin(candidate)) {
            return _cleanVinForOcr(candidate);
          }
        }
      }
    }
    
    // If still not found, look for any 17-character alphanumeric sequence
    String allText = text.replaceAll(RegExp(r'[^A-Z0-9]'), '').toUpperCase();
    for (int i = 0; i <= allText.length - 17; i++) {
      String candidate = allText.substring(i, i + 17);
      if (_isLikelyVin(candidate)) {
        return _cleanVinForOcr(candidate);
      }
    }
    
    return '';
  }
  
  /// Check if line contains VIN-related keywords
  static bool _lineContainsVinKeywords(String line) {
    String lowerLine = line.toLowerCase();
    List<String> vinKeywords = [
      'vin', 'vehicle identification', 'chassis', 'serial', 'id number',
      'رقم الهيكل', 'رقم التعريف', 'هوية المركبة'
    ];
    
    return vinKeywords.any((keyword) => lowerLine.contains(keyword));
  }
  
  /// Dispose the text recognizer
  static Future<void> dispose() async {
    await _textRecognizer.close();
  }
}