import 'package:get/get.dart';
import '../../../data/providers/auth_provider.dart';

class HomeController extends GetxController {
  final AuthProvider _authProvider = Get.find<AuthProvider>();

  String? get userEmail => _authProvider.currentUser?.email;
}
