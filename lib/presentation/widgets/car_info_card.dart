import 'package:flutter/material.dart';
import '../../domain/entities/car_info.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class CarInfoCard extends StatelessWidget {
  final CarInfo carInfo;
  
  const CarInfoCard({
    super.key,
    required this.carInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.directions_car,
                  color: AppColors.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.carInfo,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        '${carInfo.brand} ${carInfo.model} ${carInfo.year}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Car Details
            _buildInfoRow(
              context,
              icon: Icons.business,
              label: AppStrings.carBrand,
              value: carInfo.brand,
            ),
            
            _buildInfoRow(
              context,
              icon: Icons.car_rental,
              label: AppStrings.carModel,
              value: carInfo.model,
            ),
            
            _buildInfoRow(
              context,
              icon: Icons.calendar_today,
              label: AppStrings.carYear,
              value: carInfo.year.toString(),
            ),
            
            if (carInfo.vin != null)
              _buildInfoRow(
                context,
                icon: Icons.qr_code,
                label: AppStrings.vinNumber,
                value: carInfo.vin!,
                isMonospace: true,
              ),
            
            if (carInfo.engineType != null)
              _buildInfoRow(
                context,
                icon: Icons.engineering,
                label: 'نوع المحرك',
                value: carInfo.engineType!,
              ),
            
            if (carInfo.engineDisplacement != null)
              _buildInfoRow(
                context,
                icon: Icons.speed,
                label: 'سعة المحرك',
                value: carInfo.engineDisplacement!,
              ),
            
            if (carInfo.bodyStyle != null)
              _buildInfoRow(
                context,
                icon: Icons.drive_eta,
                label: 'نوع الهيكل',
                value: carInfo.bodyStyle!,
              ),
            
            if (carInfo.fuelType != null)
              _buildInfoRow(
                context,
                icon: Icons.local_gas_station,
                label: 'نوع الوقود',
                value: carInfo.fuelType!,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isMonospace = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                fontFamily: isMonospace ? 'monospace' : null,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}