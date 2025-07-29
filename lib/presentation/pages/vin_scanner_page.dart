import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';
import '../controllers/vin_scanner_controller.dart';
import '../widgets/loading_widget.dart';

class VinScannerPage extends StatelessWidget {
  const VinScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VinScannerController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.vinScannerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          Obx(() => IconButton(
            onPressed: controller.toggleFlash,
            icon: Icon(
              controller.isFlashOn.value ? Icons.flash_on : Icons.flash_off,
            ),
          )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: AppStrings.loadingImage);
        }
        
        if (controller.cameraController.value?.value.isInitialized == true) {
          return Stack(
            children: [
              // Camera Preview
              Positioned.fill(
                child: CameraPreview(controller.cameraController.value!),
              ),
              
              // VIN Detection Overlay
              Positioned.fill(
                child: _buildDetectionOverlay(context, controller),
              ),
              
              // Bottom Controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomControls(context, controller),
              ),
            ],
          );
        }
        
        return _buildCameraError(context, controller);
      }),
    );
  }
  
  Widget _buildDetectionOverlay(BuildContext context, VinScannerController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
      ),
      child: Stack(
        children: [
          // Instructions
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.vinScannerHint,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.vinScannerInstructions,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          // VIN Detection Frame
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(
                  color: controller.isDetecting.value ? AppColors.success : AppColors.warning,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Obx(() => controller.detectedVin.value.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.detectedVin.value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : null),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomControls(BuildContext context, VinScannerController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Gallery Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.pickImageFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text(AppStrings.galleryPicker),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Capture Button
            GestureDetector(
              onTap: controller.captureImage,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Retake Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.retakePhoto,
                icon: const Icon(Icons.refresh),
                label: const Text(AppStrings.retakePhoto),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCameraError(BuildContext context, VinScannerController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.errorCameraPermission,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.initializeCamera,
              icon: const Icon(Icons.refresh),
              label: const Text(AppStrings.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}