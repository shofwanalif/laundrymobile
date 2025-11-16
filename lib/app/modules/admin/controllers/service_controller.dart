import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:laundrymobile/app/core/theme/app_colors.dart';
import '../../../data/providers/services_provider.dart';
import '../../../data/models/services_model.dart';

class ServiceController extends GetxController {
  final ServicesProvider _servicesProvider = Get.find();

  final services = <ServicesModel>[].obs;
  final isLoading = false.obs;

  final serviceNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }

  @override
  void onClose() {
    serviceNameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.onClose();
  }

  Future<void> fetchServices() async {
    try {
      isLoading.value = true;
      final result = await _servicesProvider.getServices();
      services.value = result;
      debugPrint('Fetched ${result.length} services');
    } catch (e) {
      Get.snackbar(
        "error!",
        "failed to fetch services: $e",
        colorText: AppColors.white,
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createServices() async {
    if (!_validateForm()) return;

    try {
      isLoading.value = true;

      final newServices = ServicesModel(
        serviceName: serviceNameController.text.trim(),
        description: descriptionController.text.trim(),
        price: int.parse(priceController.text.trim()),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _servicesProvider.createService(newServices);

      Get.back();
      _clearForm();
      fetchServices();

      Get.snackbar(
        'Success',
        'Service created successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create service: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateService(ServicesModel service) async {
    if (!_validateForm()) return;

    try {
      isLoading.value = true;

      final updatedService = service.copyWith(
        serviceName: serviceNameController.text.trim(),
        description: descriptionController.text.trim(),
        price: int.parse(priceController.text.trim()),
        updatedAt: DateTime.now(),
      );

      await _servicesProvider.updateService(updatedService);

      Get.back();
      _clearForm();
      fetchServices();

      Get.snackbar(
        'Success',
        'Service updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update service: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteService(int id, String serviceName) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete "$serviceName"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        isLoading.value = true;
        await _servicesProvider.deletedService(id);
        fetchServices(); // Refresh list

        Get.snackbar(
          'Success',
          'Service deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to delete service: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  bool _validateForm() {
    if (serviceNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Service name is required',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Description is required',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (priceController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Price is required',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    final price = int.tryParse(priceController.text.trim());
    if (price == null || price <= 0) {
      Get.snackbar(
        'Validation Error',
        'Please enter a valid price',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  void editService(ServicesModel service) {
    serviceNameController.text = service.serviceName;
    descriptionController.text = service.description;
    priceController.text = service.price.toString();
  }

  void _clearForm() {
    serviceNameController.clear();
    descriptionController.clear();
    priceController.clear();
  }
}
