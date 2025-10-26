import 'package:get/get.dart';
import '../../../data/services/dio_map_service.dart';
import '../../../data/services/dio_menu_service.dart';
import '../controllers/dio_controller.dart';

class DioBinding implements Bindings {
  @override
  void dependencies() {
    // Register services
    Get.lazyPut<MenuService>(() => MenuService(), fenix: true);
    Get.lazyPut<MapsService>(() => MapsService(), fenix: true);
    
    // Register controller
    Get.lazyPut<DioController>(() => DioController(
      menuService: Get.find<MenuService>(),
      mapsService: Get.find<MapsService>(),
    ));
  }
}