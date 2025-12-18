import 'package:get/get.dart';
import '../../../data/models/service_model.dart';
import '../../../data/providers/order_provider.dart';
import '../../../core/order_status.dart';
import '../../../data/providers/auth_provider.dart';

class OrderController extends GetxController {
  final OrderProvider _orderProvider = Get.find();
  final AuthProvider _authProvider = Get.find();

  late final ServiceModel service;

  final weight = 1.0.obs;
  final isSubmitting = false.obs;

  int get totalPrice =>
      (service.pricePerKg * weight.value).round();

  String get userId {
    final user = _authProvider.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.id;
  }

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args == null || args is! ServiceModel) {
      Get.back();
      Get.snackbar(
        'Error',
        'Data layanan tidak valid',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    service = args;
  }

  // ===================== WEIGHT =====================

  void increaseWeight() => weight.value += 0.5;

  void decreaseWeight() {
    if (weight.value > 0.5) {
      weight.value -= 0.5;
    }
  }

  // ===================== SUBMIT ORDER =====================

  Future<void> submitOrder() async {
    if (isSubmitting.value) return;

    try {
      isSubmitting.value = true;

      final orderData = {
        'user_id': userId,
        'service_id': service.id,
        'weight': weight.value,
        'total_price': totalPrice,
        'status': OrderStatus.pending,
      };

      await _orderProvider.createOrder(orderData);

      Get.back();

      Get.snackbar(
        'Berhasil',
        'Pesanan ${service.name} berhasil dibuat',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Gagal membuat pesanan',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Submit order error: $e');
    } finally {
      isSubmitting.value = false;
    }
  }
}
