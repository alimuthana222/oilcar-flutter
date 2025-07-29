import 'package:flutter/material.dart';
import '../../domain/entities/oil_specification.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class OilSpecsWidget extends StatelessWidget {
  final OilSpecification oilSpec;
  final VoidCallback? onTap;
  
  const OilSpecsWidget({
    super.key,
    required this.oilSpec,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.oil_barrel,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          oilSpec.oilType,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        if (oilSpec.oilBrandRecommendation != null)
                          Text(
                            oilSpec.oilBrandRecommendation!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (oilSpec.isSynthetic)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'صناعي',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Main Specifications
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildSpecRow(
                      context,
                      icon: Icons.water_drop,
                      label: AppStrings.capacityWithFilter,
                      value: '${oilSpec.oilCapacityWithFilter} ${oilSpec.oilCapacityUnit}',
                      color: AppColors.primary,
                    ),
                    
                    _buildSpecRow(
                      context,
                      icon: Icons.water_drop_outlined,
                      label: AppStrings.capacityWithoutFilter,
                      value: '${oilSpec.oilCapacityWithoutFilter} ${oilSpec.oilCapacityUnit}',
                      color: AppColors.secondary,
                    ),
                    
                    if (oilSpec.viscosityGrade != null)
                      _buildSpecRow(
                        context,
                        icon: Icons.thermostat,
                        label: AppStrings.viscosityGrade,
                        value: oilSpec.viscosityGrade!,
                        color: AppColors.accent,
                      ),
                    
                    if (oilSpec.oilChangeIntervalKm != null)
                      _buildSpecRow(
                        context,
                        icon: Icons.schedule,
                        label: AppStrings.changeInterval,
                        value: '${oilSpec.oilChangeIntervalKm} ${AppStrings.kmUnit}',
                        color: AppColors.warning,
                      ),
                  ],
                ),
              ),
              
              // Additional Information
              if (oilSpec.filterType != null || 
                  oilSpec.drainPlugTorque != null || 
                  oilSpec.apiCertification != null) ...[
                const SizedBox(height: 12),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (oilSpec.filterType != null)
                      _buildInfoChip(
                        context,
                        icon: Icons.filter_alt,
                        label: 'فلتر: ${oilSpec.filterType}',
                        color: AppColors.info,
                      ),
                    
                    if (oilSpec.drainPlugTorque != null)
                      _buildInfoChip(
                        context,
                        icon: Icons.settings_applications,
                        label: 'العزم: ${oilSpec.drainPlugTorque}',
                        color: AppColors.warning,
                      ),
                    
                    if (oilSpec.apiCertification != null)
                      _buildInfoChip(
                        context,
                        icon: Icons.verified,
                        label: 'API: ${oilSpec.apiCertification}',
                        color: AppColors.success,
                      ),
                  ],
                ),
              ],
              
              // Special Notes
              if (oilSpec.specialNotes != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          oilSpec.specialNotes!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.warning.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Tap hint
              if (onTap != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app,
                      size: 16,
                      color: AppColors.textSecondary.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'اضغط لعرض التفاصيل الكاملة',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSpecRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}