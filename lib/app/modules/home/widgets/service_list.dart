import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'service_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/service_model.dart';

class ServiceList extends GetView<HomeController> {
  final void Function(ServiceModel service)? onServiceTap;

  const ServiceList({super.key, this.onServiceTap});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.services.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.hasError.value && controller.services.isEmpty) {
        return _buildErrorWidget();
      }

      if (controller.services.isEmpty) {
        return _buildEmptyWidget();
      }

      return RefreshIndicator(
        onRefresh: controller.refreshData,
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72, // Diubah agar kartu sedikit lebih tinggi
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: controller.services.length,
          itemBuilder: (context, index) {
            final service = controller.services[index];
            return HomeServiceCard(
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text("Gagal memuat data"),
          TextButton(
            onPressed: controller.loadServices,
            child: const Text("Coba Lagi"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return const Center(child: Text("Tidak ada layanan tersedia"));
  }
}
