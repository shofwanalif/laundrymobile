import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/services_model.dart';
import '../controllers/service_controller.dart';

class ServiceFormView extends GetView<ServiceController> {
  const ServiceFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final ServicesModel? service = Get.arguments as ServicesModel?;
    final isEdit = service != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Service' : 'Add Service'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Service Name
            TextField(
              controller: controller.serviceNameController,
              decoration: InputDecoration(
                labelText: 'Service Name',
                hintText: 'e.g., Cuci Kering',
                prefixIcon: const Icon(Icons.cleaning_services),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Description
            TextField(
              controller: controller.descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Describe the service',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Price
            TextField(
              controller: controller.priceController,
              decoration: InputDecoration(
                labelText: 'Price (Rp)',
                hintText: '0',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 24),

            // Submit Button
            Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () {
                        if (isEdit) {
                          controller.updateService(service);
                        } else {
                          controller.createServices();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        isEdit ? 'Update Service' : 'Create Service',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),

            if (isEdit) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () {
                        controller.serviceNameController.clear();
                        controller.descriptionController.clear();
                        controller.priceController.clear();
                        Get.back();
                      },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cancel', style: TextStyle(fontSize: 16)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
