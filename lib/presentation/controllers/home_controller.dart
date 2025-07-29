import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../pages/vin_scanner_page.dart';
import '../pages/manual_input_page.dart';

class HomeController extends GetxController {
  void navigateToVinScanner() {
    Get.to(() => const VinScannerPage());
  }
  
  void navigateToImagePicker() {
    // Use the same VIN scanner page but trigger image picker
    Get.to(() => const VinScannerPage());
  }
  
  void navigateToManualVin() {
    // Navigate to manual input page with VIN focus
    Get.to(() => const ManualInputPage());
  }
  
  void navigateToManualInput() {
    Get.to(() => const ManualInputPage());
  }
  
  void navigateToHistory() {
    // TODO: Navigate to search history page
    Get.snackbar(
      'قريباً',
      'سيتم إضافة تاريخ البحث قريباً',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void navigateToSettings() {
    // TODO: Navigate to settings page
    Get.snackbar(
      'قريباً',
      'سيتم إضافة الإعدادات قريباً',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}