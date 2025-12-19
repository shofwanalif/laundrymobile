import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laundrymobile/app/core/theme/app_colors.dart';
import 'package:quickalert/quickalert.dart';
import '../../../data/providers/services_provider.dart';
import '../../../data/models/services_model.dart';

class ServiceController extends GetxController {
  final ServicesProvider _servicesProvider = Get.find();
  final ImagePicker _imagePicker = ImagePicker();

  final services = <ServicesModel>[].obs;
  final isLoading = false.obs;

  // Image picker state
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString currentImageUrl = ''.obs;

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

  /// Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
        debugPrint('Image picked from gallery: ${pickedFile.path}');
      }
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Pick image from camera
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
        debugPrint('Image picked from camera: ${pickedFile.path}');
      }
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      Get.snackbar(
        'Error',
        'Failed to take photo: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Remove selected image
  void removeSelectedImage() {
    selectedImage.value = null;
    currentImageUrl.value = '';
  }

  /// Show image source picker dialog
  void showImageSourceDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Image Source',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Gallery'),
              onTap: () {
                Get.back();
                pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('Camera'),
              onTap: () {
                Get.back();
                pickImageFromCamera();
              },
            ),
            if (selectedImage.value != null || currentImageUrl.value.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Image'),
                onTap: () {
                  Get.back();
                  removeSelectedImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> createServices() async {
    if (!_validateForm()) return;

    try {
      isLoading.value = true;

      String? imageUrl;

      // Upload image if selected
      if (selectedImage.value != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        imageUrl = await _servicesProvider.uploadServiceImage(
          selectedImage.value!,
          fileName,
        );
      }

      final newServices = ServicesModel(
        serviceName: serviceNameController.text.trim(),
        description: descriptionController.text.trim(),
        price: int.parse(priceController.text.trim()),
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _servicesProvider.createService(newServices);

      Get.back();
      _clearForm();
      fetchServices();

      QuickAlert.show(
        context: Get.context!,
        type: QuickAlertType.success,
        title: 'Success',
        text: 'Service created successfully',
      );
    } catch (e) {
      QuickAlert.show(
        context: Get.context!,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'Failed to create service: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateService(ServicesModel service) async {
    if (!_validateForm()) return;

    try {
      isLoading.value = true;

      String? imageUrl = service.imageUrl;

      // Upload new image if selected
      if (selectedImage.value != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        imageUrl = await _servicesProvider.uploadServiceImage(
          selectedImage.value!,
          fileName,
        );

        // Delete old image if exists
        if (service.imageUrl != null && service.imageUrl!.isNotEmpty) {
          await _servicesProvider.deleteServiceImage(service.imageUrl!);
        }
      }

      // If image was removed
      if (currentImageUrl.value.isEmpty && service.imageUrl != null) {
        await _servicesProvider.deleteServiceImage(service.imageUrl!);
        imageUrl = null;
      }

      final updatedService = service.copyWith(
        serviceName: serviceNameController.text.trim(),
        description: descriptionController.text.trim(),
        price: int.parse(priceController.text.trim()),
        imageUrl: imageUrl,
        updatedAt: DateTime.now(),
      );

      await _servicesProvider.updateService(updatedService);

      Get.back();
      _clearForm();
      fetchServices();

      QuickAlert.show(
        context: Get.context!,
        type: QuickAlertType.success,
        title: 'Success',
        text: 'Service updated successfully',
      );
    } catch (e) {
      QuickAlert.show(
        context: Get.context!,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'Failed to update service: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteService(
    int id,
    String serviceName, {
    String? imageUrl,
  }) async {
    QuickAlert.show(
      context: Get.context!,
      type: QuickAlertType.confirm,
      title: 'Delete Service',
      text: 'Are you sure you want to delete "$serviceName"?',
      confirmBtnText: 'Delete',
      cancelBtnText: 'Cancel',
      confirmBtnColor: Colors.red,
      onConfirmBtnTap: () async {
        Get.back();

        try {
          isLoading.value = true;

          // Delete image from storage if exists
          if (imageUrl != null && imageUrl.isNotEmpty) {
            await _servicesProvider.deleteServiceImage(imageUrl);
          }

          await _servicesProvider.deletedService(id);
          fetchServices();

          QuickAlert.show(
            context: Get.context!,
            type: QuickAlertType.success,
            title: 'Deleted!',
            text: 'Service deleted successfully',
          );
        } catch (e) {
          QuickAlert.show(
            context: Get.context!,
            type: QuickAlertType.error,
            title: 'Error',
            text: 'Failed to delete service: $e',
          );
        } finally {
          isLoading.value = false;
        }
      },
    );
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
    currentImageUrl.value = service.imageUrl ?? '';
    selectedImage.value = null;
  }

  void _clearForm() {
    serviceNameController.clear();
    descriptionController.clear();
    priceController.clear();
    selectedImage.value = null;
    currentImageUrl.value = '';
  }
}
