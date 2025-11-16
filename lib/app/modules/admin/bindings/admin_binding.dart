import 'package:get/get.dart';
import '../controllers/admin_controller.dart';
import '../../auth/controllers/auth_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminController>(() => AdminController());
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
