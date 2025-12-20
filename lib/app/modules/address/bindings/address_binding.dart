import 'package:get/get.dart';
import '../controllers/address_controller.dart';
import '../../../data/providers/address_provider.dart';

class AddressBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddressProvider>(() => AddressProvider());
    Get.lazyPut<AddressController>(() => AddressController());
  }
}
