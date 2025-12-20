import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/service_model.dart';
import '../../../data/services/service_data_service.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  final AuthProvider _authProvider = Get.find<AuthProvider>();
  final ServicesDataService _servicesDataService =
      Get.find<ServicesDataService>();

  // Auth related
  String? get userEmail => _authProvider.currentUser?.email;

  // Reactive states
  final RxList<ServiceModel> services = <ServiceModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;
  final RxBool isOfflineMode = false.obs;
  final RxBool isConnected = true.obs;

  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    loadServices();
  }

  Future<void> _initConnectivity() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      _updateConnectionStatus(connectivityResult);

      // Listen for connectivity changes
      _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    } catch (e) {
      print("Error checking connectivity: $e");
    }
  }

  // Update connection status
  void _updateConnectionStatus(ConnectivityResult result) {
    isConnected.value = result != ConnectivityResult.none;

    if (!isConnected.value && _servicesDataService.hasCachedData()) {
      isOfflineMode.value = true;
    } else if (isConnected.value) {
      isOfflineMode.value = false;
    }
  }

  // Load service list
  Future<void> loadServices() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Load cached data first
      if (_servicesDataService.hasCachedData()) {
        services.assignAll(_servicesDataService.getCachedServices());
        if (!isConnected.value) {
          isOfflineMode.value = true;
        }
      }

      // Fetch from API if connected
      if (isConnected.value) {
        final fetched = await _servicesDataService.getServices();
        services.assignAll(fetched);
        isOfflineMode.value = false;
        return;
      }

      // If offline and no cache
      if (!isConnected.value && !(_servicesDataService.hasCachedData())) {
        hasError.value = true;
        errorMessage.value = 'Tidak ada koneksi & data local tidak tersedia.';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();

      if (_servicesDataService.hasCachedData()) {
        isOfflineMode.value = true; // fallback
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final connectivityResult = await _connectivity.checkConnectivity();
      isConnected.value = connectivityResult != ConnectivityResult.none;

      if (!isConnected.value) {
        isOfflineMode.value = true;
        return;
      }

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
      Get.snackbar(
        'Error',
        'Gagal melakukan logout: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Perform actual logout
  Future<void> _performLogout() async {
    try {
      isLoading.value = true;
      await _authProvider.logout();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal logout: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void goToOrderHistory() {
    Get.toNamed(Routes.ORDERS_HISTORY);
  }

  void goToMyOrders() {
    Get.toNamed(Routes.MY_ORDERS);
  }

  void goToAddress() {
    Get.toNamed(Routes.ADDRESS);
  }

  // Getters
  List<ServiceModel> get servicesList => services.toList();
  bool get hasData => services.isNotEmpty;
}
