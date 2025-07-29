import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';
import '../controllers/manual_input_controller.dart';
import '../widgets/loading_widget.dart';

class ManualInputPage extends StatelessWidget {
  const ManualInputPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ManualInputController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.manualInputTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: AppStrings.loadingData);
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.directions_car,
                          size: 48,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.manualInputTitle,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'أدخل تفاصيل سيارتك للحصول على مواصفات الزيت المناسبة',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // VIN Input (Optional)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.vinNumber,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: controller.vinController,
                          decoration: InputDecoration(
                            hintText: 'أدخل رقم VIN (اختياري)',
                            prefixIcon: const Icon(Icons.qr_code),
                            suffixIcon: IconButton(
                              onPressed: controller.clearVin,
                              icon: const Icon(Icons.clear),
                            ),
                          ),
                          textInputAction: TextInputAction.next,
                          onChanged: controller.onVinChanged,
                          validator: controller.validateVin,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'إذا كان لديك رقم VIN، فسيتم ملء البيانات تلقائياً',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Car Brand
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.carBrand,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(() => DropdownButtonFormField<String>(
                          value: controller.selectedBrand.value.isEmpty ? null : controller.selectedBrand.value,
                          decoration: const InputDecoration(
                            hintText: 'اختر العلامة التجارية',
                            prefixIcon: Icon(Icons.business),
                          ),
                          items: controller.brandSuggestions.map((brand) {
                            return DropdownMenuItem(
                              value: brand,
                              child: Text(brand),
                            );
                          }).toList(),
                          onChanged: controller.onBrandChanged,
                          validator: controller.validateBrand,
                        )),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Car Model
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.carModel,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(() => DropdownButtonFormField<String>(
                          value: controller.selectedModel.value.isEmpty ? null : controller.selectedModel.value,
                          decoration: const InputDecoration(
                            hintText: 'اختر الموديل',
                            prefixIcon: Icon(Icons.car_rental),
                          ),
                          items: controller.modelSuggestions.map((model) {
                            return DropdownMenuItem(
                              value: model,
                              child: Text(model),
                            );
                          }).toList(),
                          onChanged: controller.onModelChanged,
                          validator: controller.validateModel,
                        )),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Car Year
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.carYear,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(() => DropdownButtonFormField<int>(
                          value: controller.selectedYear.value == 0 ? null : controller.selectedYear.value,
                          decoration: const InputDecoration(
                            hintText: 'اختر سنة الصنع',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          items: controller.yearSuggestions.map((year) {
                            return DropdownMenuItem(
                              value: year,
                              child: Text(year.toString()),
                            );
                          }).toList(),
                          onChanged: controller.onYearChanged,
                          validator: controller.validateYear,
                        )),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: controller.clearForm,
                        icon: const Icon(Icons.clear),
                        label: const Text(AppStrings.clear),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textSecondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: controller.searchOilSpecs,
                        icon: const Icon(Icons.search),
                        label: const Text(AppStrings.search),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Additional Info Card
                Card(
                  color: AppColors.info.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.info,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'نصائح للحصول على أفضل النتائج',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.info,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• تأكد من كتابة اسم العلامة التجارية والموديل بشكل صحيح\n'
                          '• اختر السنة الصحيحة للحصول على مواصفات دقيقة\n'
                          '• استخدم رقم VIN للحصول على أدق النتائج',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}