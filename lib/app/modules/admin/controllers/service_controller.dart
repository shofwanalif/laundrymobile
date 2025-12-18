import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/providers/service_provider.dart';
import '../../../data/models/service_model.dart';

class ServiceController extends GetxController {
  final ServicesProvider _servicesProvider = Get.find();

  final services = <ServiceModel>[].obs;
  final isLoading = false.obs;

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final durationController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    durationController.dispose();
    super.onClose();
  }

  /// ================= FETCH =================
  Future<void> fetchServices() async {
    try {
      isLoading.value = true;
      final result = await _servicesProvider.getServices();
      services.assignAll(result);
    } catch (e) {
      _showError('Failed to fetch services: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= CREATE =================
  Future<void> createService() async {
    if (!_validateForm()) return;

    try {
      isLoading.value = true;

      final newService = ServiceModel(
        id: '', // diabaikan saat insert (UUID dari Supabase)
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        pricePerKg: int.parse(priceController.text.trim()),
        duration: durationController.text.trim(),
      );

      await _servicesProvider.createService(newService);

      Get.back();
      clearForm();
      fetchServices();

      _showSuccess('Service created successfully');
    } catch (e) {
      _showError('Failed to create service: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= UPDATE =================
  Future<void> updateService(ServiceModel service) async {
    if (!_validateForm()) return;

    try {
      isLoading.value = true;

      final updatedService = service.copyWith(
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        pricePerKg: int.parse(priceController.text.trim()),
        duration: durationController.text.trim(),
      );

      await _servicesProvider.updateService(updatedService);

      Get.back();
      clearForm();
      fetchServices();

      _showSuccess('Service updated successfully');
    } catch (e) {
      _showError('Failed to update service: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= DELETE =================
  Future<void> deleteService(ServiceModel service) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete "${service.name}"?'),
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
        await _servicesProvider.deleteService(service.id);
        fetchServices();
        _showSuccess('Service deleted successfully');
      } catch (e) {
        _showError('Failed to delete service: $e');
      } finally {
        isLoading.value = false;
      }
    }
  }

  /// ================= FORM =================
  void editService(ServiceModel service) {
    nameController.text = service.name;
    descriptionController.text = service.description;
    priceController.text = service.pricePerKg.toString();
    durationController.text = service.duration;
  }

  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    durationController.clear();
  }

  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      _showValidation('Service name is required');
      return false;
    }

    if (priceController.text.trim().isEmpty ||
        int.tryParse(priceController.text.trim()) == null) {
      _showValidation('Valid price is required');
      return false;
    }

    if (durationController.text.trim().isEmpty) {
      _showValidation('Duration is required');
      return false;
    }

    return true;
  }

  /// ================= UI HELPERS =================
  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void _showValidation(String message) {
    Get.snackbar(
      'Validation Error',
      message,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }
}
