import 'package:get/get.dart';
import '../../../data/providers/order_provider.dart';
import '../controllers/order_controller.dart';

class OrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderProvider>(() => OrderProvider());
    Get.lazyPut<OrderController>(() => OrderController());
  }
}
