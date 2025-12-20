import 'package:get/get.dart';
import '../controllers/add_address_controller.dart';
import '../../../data/services/location_service.dart';

/// Binding untuk Location Module
/// Menginisialisasi LocationController dan LocationService
class AddAddressBinding extends Bindings {
  @override
  void dependencies() {
    // Register LocationService sebagai singleton
    Get.lazyPut<LocationService>(() => LocationService(), fenix: true);

    // Register LocationController
    Get.lazyPut<AddAddressController>(
      () => AddAddressController(),
      fenix: true,
    );
  }
}
