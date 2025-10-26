// packages/services/controller/services_controller.dart
import 'package:get/get.dart';
import '../../../data/models/laundry_service.dart';
import '../../../data/services/dio_map_service.dart';
import '../../../data/services/dio_menu_service.dart';

class DioController extends GetxController {
  final MenuService menuService;
  final MapsService mapsService;

  DioController({
    required this.menuService,
    required this.mapsService,
  });

  // Reactive variables
  final RxList<LaundryService> services = <LaundryService>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString shopAddress = 'Mengambil alamat...'.obs;
  final RxBool hasLocationData = false.obs;
  final RxString debugInfo = ''.obs;
  final RxBool isAddressLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    debugInfo.value = 'Controller initialized';
    loadAllData();
  }

  Future<void> loadAllData() async {
    try {
      debugInfo.value = 'Starting loadAllData...';
      isLoading.value = true;
      errorMessage.value = '';
      isAddressLoading.value = true;
      
      print('🔄 [DEBUG] Starting chain request...');
      
      // CHAIN REQUEST: Load services dan alamat secara parallel
      await Future.wait([
        loadServices(),
        loadShopAddress(),
      ], eagerError: true);
      
      print('✅ [DEBUG] Chain request completed');
      debugInfo.value = 'Data loaded successfully';
      
    } catch (e) {
      print('❌ [DEBUG] Error in loadAllData: $e');
      debugInfo.value = 'Error: $e';
      errorMessage.value = 'Gagal memuat data: $e';
    } finally {
      isLoading.value = false;
      isAddressLoading.value = false;
      print('🏁 [DEBUG] loadAllData finished');
    }
  }

  Future<void> loadServices() async {
    try {
      print('📡 [DEBUG] Loading services from API...');
      final data = await menuService.getServices();
      print('✅ [DEBUG] Services loaded: ${data.length} items');
      
      services.assignAll(
        data.map((json) => LaundryService.fromJson(json)).toList()
      );
      
      debugInfo.value = '${data.length} services loaded';
      
    } catch (e) {
      print('❌ [DEBUG] Error loading services: $e');
      debugInfo.value = 'Service error: $e';
      errorMessage.value = 'Gagal memuat layanan: $e';
      services.clear();
      rethrow;
    }
  }

  Future<void> loadShopAddress() async {
    try {
      print('🗺️ [DEBUG] Loading address from OSM...');
      final address = await mapsService.getShopAddress();
      print('✅ [DEBUG] Address loaded: $address');
      
      shopAddress.value = address;
      hasLocationData.value = true;
      debugInfo.value = 'Address loaded from OSM';
      
    } catch (e) {
      print('❌ [DEBUG] Error loading address: $e');
      shopAddress.value = 'Jl. Alamat Toko Mitra (Gagal mengambil alamat)';
      hasLocationData.value = false;
      debugInfo.value = 'Address error: $e';
      rethrow;
    }
  }
  void refreshData() {
    loadAllData();
  }

  void printDebugInfo() {
    print('=== DEBUG INFO ===');
    print('isLoading: ${isLoading.value}');
    print('errorMessage: ${errorMessage.value}');
    print('services count: ${services.length}');
    print('shopAddress: ${shopAddress.value}');
    print('hasLocationData: ${hasLocationData.value}');
    print('debugInfo: ${debugInfo.value}');
    print('==================');
  }

  void openMap() {
    Get.toNamed('/map', arguments: {
      'latitude': mapsService.shopLat,
      'longitude': mapsService.shopLon,
      'address': shopAddress.value,
    });
  }
}