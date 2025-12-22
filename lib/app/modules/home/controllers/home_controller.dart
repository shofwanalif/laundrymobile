import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/service_model.dart';
import '../../../data/services/service_data_service.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  final AuthProvider _authProvider = Get.find<AuthProvider>();
  final ServicesDataService _servicesDataService = Get.find<ServicesDataService>();

  // --- Auth Related (REFACTORED) ---
  final RxnString _userName = RxnString(); // Variabel penampung nama
  String? get userName => _userName.value; 
  String? get userEmail => _authProvider.currentUser?.email;

  // --- Reactive states (STAY THE SAME) ---
  final RxList<ServiceModel> services = <ServiceModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;
  final RxBool isOfflineMode = false.obs;
  final RxBool isConnected = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserName(); // Ambil nama saat pertama kali load
    loadServices();
  }

  // Fungsi tambahan untuk ambil nama (REFACTORED)
  Future<void> fetchUserName() async {
    try {
      final userId = _authProvider.currentUser?.id;
      if (userId != null) {
        // Panggil fungsi getUserName yang sudah ada di provider Anda
        final name = await _authProvider.getUserName(userId);
        _userName.value = name;
      }
    } catch (e) {
      _userName.value = 'Pelanggan'; // Fallback jika gagal
    }
  }

  // --- Load service list (STAY THE SAME) ---
  Future<void> loadServices() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      if (_servicesDataService.hasCachedData()) {
        services.assignAll(_servicesDataService.getCachedServices());
        if (!isConnected.value) {
          isOfflineMode.value = true;
        }
      }

      if (isConnected.value) {
        final fetched = await _servicesDataService.getServices();
        services.assignAll(fetched);
        isOfflineMode.value = false;
        return;
      }

      if (!isConnected.value && !(_servicesDataService.hasCachedData())) {
        hasError.value = true;
        errorMessage.value = 'Tidak ada koneksi & data local tidak tersedia.';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      if (_servicesDataService.hasCachedData()) {
        isOfflineMode.value = true;
      }
    } finally {
      isLoading.value = false;
    }
  }

  // --- Refresh Data (STAY THE SAME) ---
  Future<void> refreshData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      final fetchedServices = await _servicesDataService.refreshData();
      services.assignAll(fetchedServices);
      isOfflineMode.value = false;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      if (_servicesDataService.hasCachedData()) {
        isOfflineMode.value = true;
      }
    } finally {
      isLoading.value = false;
    }
  }

  // --- Logout Logic (STAY THE SAME) ---
  Future<void> logout() async {
    try {
      Get.dialog(
        AlertDialog(
          title: const Text('Logout'),
          content: const Text('Apakah Anda yakin ingin logout?'),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
            TextButton(
              onPressed: () async {
                Get.back();
                await _performLogout();
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal melakukan logout: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> _performLogout() async {
    try {
      isLoading.value = true;
      await _authProvider.logout();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Error', 'Gagal logout: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // --- Navigation & Getters (STAY THE SAME) ---
  void goToOrderHistory() => Get.toNamed(Routes.ORDERS_HISTORY);
  void goToMyOrders() => Get.toNamed(Routes.MY_ORDERS);
  void goToAddress() => Get.toNamed(Routes.ADDRESS);

  List<ServiceModel> get servicesList => services.toList();
  bool get hasData => services.isNotEmpty;
}