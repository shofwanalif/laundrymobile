import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'service_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/service_model.dart';

class ServiceList extends GetView<HomeController> {
  final void Function(ServiceModel service)? onServiceTap;

  const ServiceList({
    super.key,
    this.onServiceTap,
  });

@override
Widget build(BuildContext context) {
  return Obx(() {
    if (controller.isLoading.value && controller.services.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.hasError.value && controller.services.isEmpty) {
      return _buildErrorWidget();
    }

    if (!controller.hasData) {
      return _buildEmptyWidget();
    }

    return RefreshIndicator(
      onRefresh: controller.refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.services.length,
        itemBuilder: (context, index) {
          final service = controller.services[index];

          return ServiceCard(
            service: service,
            onTap: () => onServiceTap?.call(service),
          );
        },
      ),
    );
  });
}


  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Gagal Memuat Data', style: Get.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.loadServices,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_laundry_service,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text('Belum Ada Layanan', style: Get.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Saat ini belum ada layanan laundry yang tersedia',
              textAlign: TextAlign.center,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.loadServices,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Muat Ulang'),
            ),
          ],
        ),
      ),
    );
  }
}
