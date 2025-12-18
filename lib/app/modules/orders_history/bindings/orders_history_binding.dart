import 'package:get/get.dart';
import '../../../data/providers/order_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../controllers/orders_history_controller.dart';

class OrdersHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderProvider>(() => OrderProvider());
    Get.lazyPut<AuthProvider>(() => AuthProvider());
    Get.lazyPut<OrdersHistoryController>(() => OrdersHistoryController());
  }
}
