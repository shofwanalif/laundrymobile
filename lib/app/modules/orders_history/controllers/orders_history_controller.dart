import 'package:get/get.dart';
import '../../../data/providers/order_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/order_model.dart';

class OrdersHistoryController extends GetxController {
  final OrderProvider _orderProvider = Get.find();
  final AuthProvider _authProvider = Get.find();

  final orders = <OrderModel>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  String? get userId => _authProvider.currentUser?.id;

  @override
  void onInit() {
    super.onInit();

    if (userId == null) {
      hasError.value = true;
      errorMessage.value = 'User belum login';
      return;
    }

    fetchOrderHistory();
  }

  Future<void> fetchOrderHistory() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final response = await _orderProvider.getOrderHistory(userId!);

      orders.assignAll(
        response.map((e) => OrderModel.fromMap(e)).toList(),
      );
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Gagal memuat pesanan';
      print(e);
    } finally {
      isLoading.value = false;
    }
  }
}
