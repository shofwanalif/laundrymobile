import 'package:get/get.dart';
import 'package:flutter/material.dart'; // Tambahkan untuk snackbar/colors
import 'package:laundrymobile/app/data/models/address_model.dart';
import '../../../data/providers/address_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';

class AddressController extends GetxController {
  final AddressProvider _addressProvider = Get.find();
  final AuthProvider _authProvider = Get.find();

  final addresses = <AddressModel>[].obs;
  final isLoading = false.obs;
  final isDeleting = false.obs; // Tambahkan state untuk loading saat hapus
  final hasError = false.obs;
  final errorMessage = ''.obs;

  String get userId {
    final user = _authProvider.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.id;
  }

  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
  }

  Future<void> fetchAddresses() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final response = await _addressProvider.getUserAddresses(userId);
      addresses.value = response;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // --- FUNGSI HAPUS ALAMAT ---
  Future<void> deleteAddress(String addressId) async {
    try {
      // Tampilkan loading overlay agar user tidak klik sembarangan saat proses
      Get.showOverlay(
        asyncFunction: () async {
          await _addressProvider.deleteAddress(addressId); // Pastikan fungsi ini ada di provider
          
          // Hapus dari list lokal agar UI langsung update tanpa fetch ulang
          addresses.removeWhere((element) => element.id == addressId);
          
          Get.snackbar(
            'Berhasil',
            'Alamat telah dihapus',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        },
        loadingWidget: const Center(child: CircularProgressIndicator()),
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Gagal menghapus alamat: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }
}