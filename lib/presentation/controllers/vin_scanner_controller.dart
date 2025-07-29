import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import '../../core/utils/text_recognition.dart';
import '../../core/utils/vin_validator.dart';
import '../../core/constants/app_strings.dart';
import '../../domain/usecases/decode_vin.dart';
import '../../domain/usecases/save_search_history.dart';
import '../../core/constants/supabase_config.dart';

class VinScannerController extends GetxController {
  final DecodeVin decodeVin = Get.find<DecodeVin>();
  final SaveSearchHistory saveSearchHistory = Get.find<SaveSearchHistory>();
  
  Rx<CameraController?> cameraController = Rx<CameraController?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isFlashOn = false.obs;
  final RxBool isDetecting = false.obs;
  final RxString detectedVin = ''.obs;
  
  List<CameraDescription>? cameras;
  final ImagePicker _imagePicker = ImagePicker();
  
  @override
  void onInit() {
    super.onInit();
    initializeCamera();
  }
  
  @override
  void onClose() {
    cameraController.value?.dispose();
    super.onClose();
  }
  
  Future<void> initializeCamera() async {
    try {
      isLoading.value = true;
      
      // Request camera permission
      final cameraPermission = await Permission.camera.request();
      if (cameraPermission != PermissionStatus.granted) {
        _showError(AppStrings.errorCameraPermission);
        return;
      }
      
      // Get available cameras
      cameras = await availableCameras();
      if (cameras == null || cameras!.isEmpty) {
        _showError('No cameras found on device');
        return;
      }
      
      // Initialize camera controller
      final camera = cameras!.first;
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      
      await controller.initialize();
      cameraController.value = controller;
      
      // Start continuous image analysis for VIN detection
      _startVinDetection();
      
    } catch (e) {
      _showError('Failed to initialize camera: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  void _startVinDetection() {
    // Start periodic image capture for VIN detection
    // Note: This is a simplified implementation
    // In a real app, you'd use streaming image analysis
  }
  
  Future<void> toggleFlash() async {
    try {
      if (cameraController.value != null) {
        final currentFlashMode = isFlashOn.value ? FlashMode.off : FlashMode.torch;
        await cameraController.value!.setFlashMode(currentFlashMode);
        isFlashOn.value = !isFlashOn.value;
      }
    } catch (e) {
      _showError('Failed to toggle flash: ${e.toString()}');
    }
  }
  
  Future<void> captureImage() async {
    try {
      if (cameraController.value == null) return;
      
      isDetecting.value = true;
      
      final XFile image = await cameraController.value!.takePicture();
      await _processImage(File(image.path));
      
    } catch (e) {
      _showError('Failed to capture image: ${e.toString()}');
    } finally {
      isDetecting.value = false;
    }
  }
  
  Future<void> pickImageFromGallery() async {
    try {
      isDetecting.value = true;
      
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (image != null) {
        await _processImage(File(image.path));
      }
      
    } catch (e) {
      _showError('Failed to pick image: ${e.toString()}');
    } finally {
      isDetecting.value = false;
    }
  }
  
  Future<void> _processImage(File imageFile) async {
    try {
      isLoading.value = true;
      
      // Extract text from image using OCR
      final extractedText = await TextRecognitionService.recognizeFromFile(imageFile);
      
      if (extractedText.isEmpty) {
        _showError(AppStrings.errorImageProcessing);
        return;
      }
      
      // Validate if the extracted text is a valid VIN
      if (!VinValidator.isValidFormat(extractedText)) {
        _showError('No valid VIN found in image');
        return;
      }
      
      detectedVin.value = extractedText;
      
      // Show success message
      Get.snackbar(
        AppStrings.vinDetected,
        'VIN: ${VinValidator.formatVin(extractedText)}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      
      // Proceed to decode VIN
      await _decodeDetectedVin(extractedText);
      
    } catch (e) {
      _showError('Failed to process image: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> _decodeDetectedVin(String vin) async {
    try {
      isLoading.value = true;
      
      final result = await decodeVin.call(vin);
      
      if (result.isSuccess) {
        final carInfo = result.value;
        
        // Save to search history
        await saveSearchHistory.call(SearchHistoryParams(
          deviceId: await _getDeviceId(),
          vinNumber: vin,
          brand: carInfo.brand,
          model: carInfo.model,
          year: carInfo.year,
          searchMethod: SearchMethods.vinScan,
          resultFound: true,
        ));
        
        // Navigate to results page
        Get.offNamed('/results', arguments: {
          'carInfo': carInfo,
          'vin': vin,
        });
        
      } else {
        // Save failed search to history
        await saveSearchHistory.call(SearchHistoryParams(
          deviceId: await _getDeviceId(),
          vinNumber: vin,
          searchMethod: SearchMethods.vinScan,
          resultFound: false,
        ));
        
        _showError(result.error.message);
      }
      
    } catch (e) {
      _showError('Failed to decode VIN: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  void retakePhoto() {
    detectedVin.value = '';
    isDetecting.value = false;
  }
  
  Future<String?> _getDeviceId() async {
    // In a real app, you'd get the actual device ID
    // For now, return a placeholder
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