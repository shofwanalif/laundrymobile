import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../controllers/service_controller.dart';
import '../widgets/service_card.dart';
import '../widgets/service_form_bottom_sheet.dart';

class ServicesListView extends GetView<ServiceController> {
  const ServicesListView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Manage Services',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => showServiceFormBottomSheet(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add, color: Colors.blue, size: 24),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.services.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.services.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cleaning_services_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No services yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => showServiceFormBottomSheet(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Service'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.fetchServices,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.services.length,
              itemBuilder: (context, index) {
                final service = controller.services[index];

                return AdminServiceCard(
                  service: service,
                  onTap: () => showServiceFormBottomSheet(service: service),
                  onEdit: () => showServiceFormBottomSheet(service: service),
                  onDelete: () {
                    controller.deleteService(
                      service.id!,
                      service.serviceName,
                      imageUrl: service.imageUrl,
                    );
                  },
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
