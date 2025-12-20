import 'package:get/get.dart';
import '../controllers/admin_order_controller.dart';
import '../../../data/providers/order_provider.dart';

class AdminOrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OrderProvider());
    Get.lazyPut(() => AdminOrderController());
  }
}
