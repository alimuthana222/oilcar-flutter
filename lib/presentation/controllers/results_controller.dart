import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/oil_specification.dart';
import '../../domain/entities/car_info.dart';
import '../../core/constants/app_strings.dart';

class ResultsController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<OilSpecification> oilSpecs = <OilSpecification>[].obs;
  final Rx<CarInfo?> carInfo = Rx<CarInfo?>(null);
  
  @override
  void onInit() {
    super.onInit();
    _loadArguments();
  }
  
  void _loadArguments() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    
    if (arguments != null) {
      // Load oil specifications
      if (arguments['oilSpecs'] != null) {
        oilSpecs.value = List<OilSpecification>.from(arguments['oilSpecs']);
      }
      
      // Load car info
      if (arguments['carInfo'] != null) {
        final carInfoData = arguments['carInfo'];
        if (carInfoData is CarInfo) {
          carInfo.value = carInfoData;
        } else if (carInfoData is Map<String, dynamic>) {
          carInfo.value = CarInfo(
            brand: carInfoData['brand'] ?? '',
            model: carInfoData['model'] ?? '',
            year: carInfoData['year'] ?? DateTime.now().year,
            vin: carInfoData['vin'],
          );
        }
      }
    }
  }
  
  void showOilSpecDetails(OilSpecification oilSpec) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Title
              Text(
                'تفاصيل مواصفات الزيت',
                style: Get.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Oil details
              _buildDetailRow('نوع الزيت', oilSpec.oilType),
              if (oilSpec.oilBrandRecommendation != null)
                _buildDetailRow('العلامة التجارية الموصى بها', oilSpec.oilBrandRecommendation!),
              _buildDetailRow('السعة مع الفلتر', '${oilSpec.oilCapacityWithFilter} ${oilSpec.oilCapacityUnit}'),
              _buildDetailRow('السعة بدون الفلتر', '${oilSpec.oilCapacityWithoutFilter} ${oilSpec.oilCapacityUnit}'),
              if (oilSpec.viscosityGrade != null)
                _buildDetailRow('درجة اللزوجة', oilSpec.viscosityGrade!),
              if (oilSpec.apiCertification != null)
                _buildDetailRow('شهادة API', oilSpec.apiCertification!),
              if (oilSpec.filterType != null)
                _buildDetailRow('نوع الفلتر', oilSpec.filterType!),
              if (oilSpec.drainPlugTorque != null)
                _buildDetailRow('عزم براغي التصريف', oilSpec.drainPlugTorque!),
              if (oilSpec.oilChangeIntervalKm != null)
                _buildDetailRow('فترة التغيير', '${oilSpec.oilChangeIntervalKm} كم'),
              if (oilSpec.oilChangeIntervalMonths != null)
                _buildDetailRow('فترة التغيير (شهور)', '${oilSpec.oilChangeIntervalMonths} شهر'),
              _buildDetailRow('زيت صناعي', oilSpec.isSynthetic ? 'نعم' : 'لا'),
              
              if (oilSpec.specialNotes != null) ...[
                const SizedBox(height: 16),
                Text(
                  'ملاحظات خاصة',
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    oilSpec.specialNotes!,
                    style: Get.textTheme.bodyMedium,
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('إغلاق'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Get.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Get.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> shareResults() async {
    try {
      final shareText = _generateShareText();
      await Share.share(shareText, subject: 'مواصفات زيت السيارة');
      
      Get.snackbar(
        'تم',
        'تم مشاركة النتائج بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في مشاركة النتائج',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  Future<void> exportToPdf() async {
    // TODO: Implement PDF export functionality
    Get.snackbar(
      'قريباً',
      'سيتم إضافة تصدير PDF قريباً',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  String _generateShareText() {
    final buffer = StringBuffer();
    
    buffer.writeln('🚗 مواصفات زيت السيارة');
    buffer.writeln('════════════════════════');
    
    if (carInfo.value != null) {
      final car = carInfo.value!;
      buffer.writeln('📋 معلومات السيارة:');
      buffer.writeln('العلامة التجارية: ${car.brand}');
      buffer.writeln('الموديل: ${car.model}');
      buffer.writeln('السنة: ${car.year}');
      if (car.vin != null) {
        buffer.writeln('رقم VIN: ${car.vin}');
      }
      buffer.writeln('');
    }
    
    for (int i = 0; i < oilSpecs.length; i++) {
      final spec = oilSpecs[i];
      buffer.writeln('🛢️ مواصفات الزيت ${i + 1}:');
      buffer.writeln('نوع الزيت: ${spec.oilType}');
      if (spec.oilBrandRecommendation != null) {
        buffer.writeln('العلامة التجارية: ${spec.oilBrandRecommendation}');
      }
      buffer.writeln('السعة مع الفلتر: ${spec.oilCapacityWithFilter} ${spec.oilCapacityUnit}');
      buffer.writeln('السعة بدون الفلتر: ${spec.oilCapacityWithoutFilter} ${spec.oilCapacityUnit}');
      if (spec.oilChangeIntervalKm != null) {
        buffer.writeln('فترة التغيير: ${spec.oilChangeIntervalKm} كم');
      }
      buffer.writeln('زيت صناعي: ${spec.isSynthetic ? "نعم" : "لا"}');
      buffer.writeln('');
    }
    
    buffer.writeln('📱 تطبيق دليل زيت السيارات');
    
    return buffer.toString();
  }
}