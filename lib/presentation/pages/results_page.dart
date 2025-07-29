import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/oil_specification.dart';
import '../../domain/entities/car_info.dart';
import '../controllers/results_controller.dart';
import '../widgets/oil_specs_widget.dart';
import '../widgets/car_info_card.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ResultsController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.resultsTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: controller.shareResults,
            icon: const Icon(Icons.share),
          ),
          IconButton(
            onPressed: controller.exportToPdf,
            icon: const Icon(Icons.picture_as_pdf),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (controller.oilSpecs.isEmpty) {
          return _buildNoResults(context, controller);
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Car Information Card
              if (controller.carInfo.value != null)
                CarInfoCard(carInfo: controller.carInfo.value!),
              
              const SizedBox(height: 16),
              
              // Oil Specifications List
              ...controller.oilSpecs.map((oilSpec) => 
                OilSpecsWidget(
                  oilSpec: oilSpec,
                  onTap: () => controller.showOilSpecDetails(oilSpec),
                ),
              ).toList(),
              
              const SizedBox(height: 16),
              
              // Action Buttons
              _buildActionButtons(context, controller),
              
              const SizedBox(height: 16),
              
              // Additional Information
              _buildAdditionalInfo(context),
            ],
          ),
        );
      }),
    );
  }
  
  Widget _buildNoResults(BuildContext context, ResultsController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.errorNoResults,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'لم يتم العثور على مواصفات زيت لهذه السيارة. يرجى التحقق من البيانات المدخلة أو المحاولة مرة أخرى.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back),
              label: const Text(AppStrings.back),
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
  
  Widget _buildActionButtons(BuildContext context, ResultsController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'الإجراءات',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.exportToPdf,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text(AppStrings.exportPdf),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.shareResults,
                    icon: const Icon(Icons.share),
                    label: const Text(AppStrings.shareResults),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.info,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.search),
              label: const Text('بحث جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAdditionalInfo(BuildContext context) {
    return Card(
      color: AppColors.warning.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 8),
                Text(
                  'معلومات مهمة',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '• تأكد من استخدام النوع المناسب من الزيت حسب توصيات الشركة المصنعة\n'
              '• قم بتغيير الزيت حسب الفترات المحددة\n'
              '• استخدم فلتر زيت أصلي أو معتمد\n'
              '• تحقق من مستوى الزيت بانتظام\n'
              '• في حالة التعديلات على المحرك، قد تحتاج لمواصفات مختلفة',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.warning.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}