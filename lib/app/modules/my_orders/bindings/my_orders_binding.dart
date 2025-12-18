import 'package:get/get.dart';
import '../../../data/providers/order_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../my_orders/controllers/my_orders_controller.dart';

class MyOrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderProvider>(() => OrderProvider());
    Get.lazyPut<AuthProvider>(() => AuthProvider());
    Get.lazyPut<MyOrdersController>(() => MyOrdersController());
  }
}
