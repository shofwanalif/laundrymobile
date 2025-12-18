import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/service_model.dart';
import '../controllers/service_controller.dart';

class ServiceFormView extends GetView<ServiceController> {
  const ServiceFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final ServiceModel? service = Get.arguments as ServiceModel?;
    final bool isEdit = service != null;

    // isi form saat edit
    if (isEdit) {
      controller.editService(service);
    }

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
            /// ================= SERVICE NAME =================
            TextField(
              controller: controller.nameController,
              decoration: InputDecoration(
                labelText: 'Service Name',
                hintText: 'e.g. Cuci Kering',
                prefixIcon: const Icon(Icons.cleaning_services),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            /// ================= DESCRIPTION =================
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

            /// ================= PRICE =================
            TextField(
              controller: controller.priceController,
              decoration: InputDecoration(
                labelText: 'Price per Kg (Rp)',
                hintText: 'e.g. 7000',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly
              ],
            ),
            const SizedBox(height: 16),

            /// ================= DURATION =================
            TextField(
              controller: controller.durationController,
              decoration: InputDecoration(
                labelText: 'Duration',
                hintText: 'e.g. 2 Days',
                prefixIcon: const Icon(Icons.timer),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            /// ================= SUBMIT =================
            Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () {
                        if (isEdit) {
                          controller.updateService(service!);
                        } else {
                          controller.createService();
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

            /// ================= CANCEL =================
            if (isEdit) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () {
                        controller.clearForm();
                        Get.back();
                      },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
