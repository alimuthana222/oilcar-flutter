import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../core/utils/vin_validator.dart';
import '../../core/constants/app_strings.dart';
import '../../domain/usecases/decode_vin.dart';
import '../../domain/usecases/get_oil_specs.dart';
import '../../domain/usecases/search_car_manual.dart';
import '../../domain/usecases/save_search_history.dart';
import '../../core/constants/supabase_config.dart';

class ManualInputController extends GetxController {
  final DecodeVin decodeVin = Get.find<DecodeVin>();
  final GetOilSpecs getOilSpecs = Get.find<GetOilSpecs>();
  final SearchCarManual searchCarManual = Get.find<SearchCarManual>();
  final SaveSearchHistory saveSearchHistory = Get.find<SaveSearchHistory>();
  
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  // Text Controllers
  final TextEditingController vinController = TextEditingController();
  
  // Observable values
  final RxBool isLoading = false.obs;
  final RxString selectedBrand = ''.obs;
  final RxString selectedModel = ''.obs;
  final RxInt selectedYear = 0.obs;
  
  // Suggestions
  final RxList<String> brandSuggestions = <String>[].obs;
  final RxList<String> modelSuggestions = <String>[].obs;
  final RxList<int> yearSuggestions = <int>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadBrandSuggestions();
    _generateYearSuggestions();
  }
  
  @override
  void onClose() {
    vinController.dispose();
    super.onClose();
  }
  
  Future<void> _loadBrandSuggestions() async {
    try {
      final result = await searchCarManual.getSuggestedBrands();
      if (result.isSuccess) {
        brandSuggestions.value = result.value;
      } else {
        // Fallback brands
        brandSuggestions.value = [
          'تويوتا', 'هوندا', 'نيسان', 'مازدا', 'ميتسوبيشي', 'سوزوكي',
          'فورد', 'شفروليه', 'جي إم سي', 'كاديلاك', 'لينكولن',
          'بي إم دبليو', 'مرسيدس بنز', 'أودي', 'فولكس فاجن',
          'هيونداي', 'كيا', 'جينيسيس', 'دايو'
        ];
      }
    } catch (e) {
      print('Failed to load brand suggestions: $e');
    }
  }
  
  void _generateYearSuggestions() {
    final currentYear = DateTime.now().year;
    final years = <int>[];
    
    // Generate years from current year down to 1990
    for (int year = currentYear + 1; year >= 1990; year--) {
      years.add(year);
    }
    
    yearSuggestions.value = years;
  }
  
  Future<void> onBrandChanged(String? brand) async {
    if (brand == null) return;
    
    selectedBrand.value = brand;
    selectedModel.value = '';
    modelSuggestions.clear();
    
    // Load models for selected brand
    await _loadModelSuggestions(brand);
  }
  
  Future<void> _loadModelSuggestions(String brand) async {
    try {
      isLoading.value = true;
      
      final result = await searchCarManual.getSuggestedModels(brand);
      if (result.isSuccess) {
        modelSuggestions.value = result.value;
      } else {
        // Fallback models based on brand
        modelSuggestions.value = _getDefaultModelsForBrand(brand);
      }
    } catch (e) {
      print('Failed to load model suggestions: $e');
      modelSuggestions.value = _getDefaultModelsForBrand(brand);
    } finally {
      isLoading.value = false;
    }
  }
  
  List<String> _getDefaultModelsForBrand(String brand) {
    switch (brand.toLowerCase()) {
      case 'تويوتا':
        return ['كامري', 'كورولا', 'يارس', 'أفالون', 'راف 4', 'هايلاندر', 'برادو', 'لاند كروزر'];
      case 'هوندا':
        return ['أكورد', 'سيفيك', 'سيتي', 'سي آر في', 'إتش آر في', 'بايلوت', 'ريدج لاين'];
      case 'نيسان':
        return ['التيما', 'سنترا', 'مكسيما', 'باثفايندر', 'روج', 'مورانو', 'أرمادا'];
      case 'فورد':
        return ['فيوجن', 'فوكس', 'إكسبلورر', 'إكسبيديشن', 'إف-150', 'رينجر', 'إسكيب'];
      case 'شفروليه':
        return ['كروز', 'ماليبو', 'إمبالا', 'تاهو', 'سوبربان', 'سيلفرادو', 'كابتيفا'];
      default:
        return ['موديل عام'];
    }
  }
  
  void onModelChanged(String? model) {
    if (model == null) return;
    selectedModel.value = model;
  }
  
  void onYearChanged(int? year) {
    if (year == null) return;
    selectedYear.value = year;
  }
  
  void onVinChanged(String vin) {
    if (vin.length == 17) {
      _decodeVinAutomatically(vin);
    }
  }
  
  Future<void> _decodeVinAutomatically(String vin) async {
    if (!VinValidator.isValidFormat(vin)) return;
    
    try {
      isLoading.value = true;
      
      final result = await decodeVin.call(vin);
      if (result.isSuccess) {
        final carInfo = result.value;
        
        // Auto-fill the form
        selectedBrand.value = carInfo.brand;
        selectedModel.value = carInfo.model;
        selectedYear.value = carInfo.year;
        
        // Load model suggestions for the brand
        await _loadModelSuggestions(carInfo.brand);
        
        Get.snackbar(
          'تم',
          'تم ملء البيانات تلقائياً من رقم VIN',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      print('Failed to decode VIN: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  String? validateVin(String? value) {
    if (value == null || value.isEmpty) {
      return null; // VIN is optional
    }
    
    if (!VinValidator.isValidFormat(value)) {
      return 'رقم VIN غير صحيح';
    }
    
    return null;
  }
  
  String? validateBrand(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى اختيار العلامة التجارية';
    }
    return null;
  }
  
  String? validateModel(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى اختيار الموديل';
    }
    return null;
  }
  
  String? validateYear(int? value) {
    if (value == null || value == 0) {
      return 'يرجى اختيار سنة الصنع';
    }
    
    final currentYear = DateTime.now().year;
    if (value < 1990 || value > currentYear + 1) {
      return 'سنة غير صحيحة';
    }
    
    return null;
  }
  
  void clearVin() {
    vinController.clear();
  }
  
  void clearForm() {
    vinController.clear();
    selectedBrand.value = '';
    selectedModel.value = '';
    selectedYear.value = 0;
    modelSuggestions.clear();
  }
  
  Future<void> searchOilSpecs() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    try {
      isLoading.value = true;
      
      final result = await getOilSpecs.call(OilSpecsParams(
        brand: selectedBrand.value,
        model: selectedModel.value,
        year: selectedYear.value,
      ));
      
      if (result.isSuccess) {
        final oilSpecs = result.value;
        
        // Save to search history
        await saveSearchHistory.call(SearchHistoryParams(
          deviceId: await _getDeviceId(),
          vinNumber: vinController.text.isEmpty ? null : vinController.text,
          brand: selectedBrand.value,
          model: selectedModel.value,
          year: selectedYear.value,
          searchMethod: SearchMethods.manualInput,
          resultFound: true,
        ));
        
        // Navigate to results page
        Get.toNamed('/results', arguments: {
          'oilSpecs': oilSpecs,
          'carInfo': {
            'brand': selectedBrand.value,
            'model': selectedModel.value,
            'year': selectedYear.value,
            'vin': vinController.text.isEmpty ? null : vinController.text,
          },
        });
        
      } else {
        // Save failed search to history
        await saveSearchHistory.call(SearchHistoryParams(
          deviceId: await _getDeviceId(),
          brand: selectedBrand.value,
          model: selectedModel.value,
          year: selectedYear.value,
          searchMethod: SearchMethods.manualInput,
          resultFound: false,
        ));
        
        _showError(result.error.message);
      }
      
    } catch (e) {
      _showError('Failed to search oil specifications: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<String?> _getDeviceId() async {
    // In a real app, you'd get the actual device ID
    return 'device_placeholder_id';
  }
  
  void _showError(String message) {
    Get.snackbar(
      AppStrings.errorGeneral,
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }
}