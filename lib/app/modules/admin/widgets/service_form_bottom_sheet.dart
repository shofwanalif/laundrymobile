import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/models/services_model.dart';
import '../../../widgets/common/input_field.dart';
import '../../../widgets/common/button.dart';
import '../controllers/service_controller.dart';

class ServiceFormBottomSheet extends GetView<ServiceController> {
  final ServicesModel? service;

  const ServiceFormBottomSheet({super.key, this.service});

  bool get isEdit => service != null;

  @override
  Widget build(BuildContext context) {
    // Initialize form if editing
    if (isEdit) {
      controller.editService(service!);
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle bar
              _buildHandleBar(),
              // Header
              _buildHeader(context),
              const Divider(height: 1),
              // Form content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image Picker
                      _buildImagePicker(),
                      const SizedBox(height: 20),

                      // Service Name
                      EmailInputFb1(
                        inputController: controller.serviceNameController,
                        label: 'Service Name',
                        hintText: 'e.g., Cuci Kering',
                      ),
                      const SizedBox(height: 16),

                      // Description
                      EmailInputFb1(
                        inputController: controller.descriptionController,
                        label: 'Description',
                        hintText: 'Describe the service',
                      ),
                      const SizedBox(height: 16),

                      // Price
                      EmailInputFb1(
                        inputController: controller.priceController,
                        label: 'Price (Rp)',
                        hintText: '0',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 24),

                      // Buttons
                      _buildButtons(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHandleBar() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isEdit ? 'Edit Service' : 'Add New Service',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: () {
              _clearAndClose();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.close, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Obx(() {
      final selectedImage = controller.selectedImage.value;
      final currentImageUrl = controller.currentImageUrl.value;

      return GestureDetector(
        onTap: controller.showImageSourceDialog,
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!, width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: _buildImageContent(selectedImage, currentImageUrl),
          ),
        ),
      );
    });
  }

  Widget _buildImageContent(File? selectedImage, String currentImageUrl) {
    if (selectedImage != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(selectedImage, fit: BoxFit.cover),
          _buildImageOverlay(),
        ],
      );
    }

    if (currentImageUrl.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            currentImageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          ),
          _buildImageOverlay(),
        ],
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 40,
          color: Colors.grey[500],
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to add image',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildImageOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit, color: Colors.white, size: 16),
            SizedBox(width: 4),
            Text(
              'Tap to change',
              style: TextStyle(color: Colors.white, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
        );
      }

      return Column(
        children: [
          Button(
            text: isEdit ? 'Update Service' : 'Create Service',
            icon: isEdit ? Icons.save : Icons.add,
            onPressed: () {
              if (isEdit) {
                controller.updateService(service!);
              } else {
                controller.createServices();
              }
            },
            width: double.infinity,
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          if (isEdit) ...[
            const SizedBox(height: 12),
            Button(
              text: 'Cancel',
              icon: Icons.close,
              gradientColors: const [Colors.grey, Colors.blueGrey],
              onPressed: _clearAndClose,
              width: double.infinity,
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ],
        ],
      );
    });
  }

  void _clearAndClose() {
    controller.serviceNameController.clear();
    controller.descriptionController.clear();
    controller.priceController.clear();
    controller.removeSelectedImage();
    Get.back();
  }
}

// Helper function to show the bottom sheet
void showServiceFormBottomSheet({ServicesModel? service}) {
  Get.bottomSheet(
    ServiceFormBottomSheet(service: service),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enterBottomSheetDuration: const Duration(milliseconds: 300),
    exitBottomSheetDuration: const Duration(milliseconds: 200),
  );
}
