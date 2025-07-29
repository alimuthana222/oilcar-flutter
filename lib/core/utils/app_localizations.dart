import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  static const Locale arabicLocale = Locale('ar', 'SA');
  static const Locale englishLocale = Locale('en', 'US');
  
  static const List<Locale> supportedLocales = [
    arabicLocale,
    englishLocale,
  ];
  
  /// Check if the current locale is Arabic (RTL)
  static bool isArabic(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ar';
  }
  
  /// Check if the current locale is RTL
  static bool isRTL(BuildContext context) {
    return isArabic(context);
  }
  
  /// Get text direction based on locale
  static TextDirection getTextDirection(BuildContext context) {
    return isRTL(context) ? TextDirection.rtl : TextDirection.ltr;
  }
  
  /// Format number with Arabic or English numerals
  static String formatNumber(num number, BuildContext context) {
    if (isArabic(context)) {
      return _toArabicNumerals(number.toString());
    }
    return NumberFormat.decimalPattern().format(number);
  }
  
  /// Convert English numerals to Arabic numerals
  static String _toArabicNumerals(String input) {
    const Map<String, String> arabicNumerals = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    };
    
    String result = input;
    arabicNumerals.forEach((english, arabic) {
      result = result.replaceAll(english, arabic);
    });
    
    return result;
  }
  
  /// Convert Arabic numerals to English numerals
  static String toEnglishNumerals(String input) {
    const Map<String, String> englishNumerals = {
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9',
    };
    
    String result = input;
    englishNumerals.forEach((arabic, english) {
      result = result.replaceAll(arabic, english);
    });
    
    return result;
  }
  
  /// Format date based on locale
  static String formatDate(DateTime date, BuildContext context) {
    if (isArabic(context)) {
      return DateFormat('dd/MM/yyyy', 'ar').format(date);
    }
    return DateFormat('MM/dd/yyyy', 'en').format(date);
  }
  
  /// Format date and time based on locale
  static String formatDateTime(DateTime dateTime, BuildContext context) {
    if (isArabic(context)) {
      return DateFormat('dd/MM/yyyy HH:mm', 'ar').format(dateTime);
    }
    return DateFormat('MM/dd/yyyy HH:mm', 'en').format(dateTime);
  }
  
  /// Get localized month name
  static String getMonthName(int month, BuildContext context) {
    const List<String> arabicMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    
    const List<String> englishMonths = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    if (month < 1 || month > 12) return '';
    
    if (isArabic(context)) {
      return arabicMonths[month - 1];
    }
    return englishMonths[month - 1];
  }
  
  /// Get localized day name
  static String getDayName(int day, BuildContext context) {
    const List<String> arabicDays = [
      'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'
    ];
    
    const List<String> englishDays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    
    if (day < 1 || day > 7) return '';
    
    if (isArabic(context)) {
      return arabicDays[day - 1];
    }
    return englishDays[day - 1];
  }
  
  /// Format file size
  static String formatFileSize(int bytes, BuildContext context) {
    const List<String> arabicUnits = ['بايت', 'ك.بايت', 'م.بايت', 'ج.بايت'];
    const List<String> englishUnits = ['B', 'KB', 'MB', 'GB'];
    
    if (bytes == 0) return '0 ${isArabic(context) ? arabicUnits[0] : englishUnits[0]}';
    
    int unitIndex = 0;
    double size = bytes.toDouble();
    
    while (size >= 1024 && unitIndex < 3) {
      size /= 1024;
      unitIndex++;
    }
    
    String formattedSize = size.toStringAsFixed(unitIndex == 0 ? 0 : 1);
    if (isArabic(context)) {
      formattedSize = _toArabicNumerals(formattedSize);
      return '$formattedSize ${arabicUnits[unitIndex]}';
    }
    
    return '$formattedSize ${englishUnits[unitIndex]}';
  }
}