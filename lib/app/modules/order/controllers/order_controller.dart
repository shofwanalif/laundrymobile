import 'package:get/get.dart';
import 'package:laundrymobile/app/data/providers/address_provider.dart';
import '../../../data/models/service_model.dart';
import '../../../data/providers/order_provider.dart';
import '../../../core/order_status.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/address_model.dart';
import 'package:flutter/material.dart';

class OrderController extends GetxController {
  final OrderProvider _orderProvider = Get.find();
  final AuthProvider _authProvider = Get.find();
  final AddressProvider _addressProvider = Get.find();

  late final ServiceModel service;

  final weight = 1.0.obs;
  var note = ''.obs; // RxString tetap dipakai untuk reactive
  late final TextEditingController noteController; // ⬅️ baru
  final isSubmitting = false.obs;

  int get totalPrice => (service.pricePerKg * weight.value).round();

  final addresses = <AddressModel>[].obs;
  final selectedAddress = Rx<AddressModel?>(null);
  final isLoadingAddress = false.obs;

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

    noteController = TextEditingController(); // ⬅️ inisialisasi controller

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

    _initOrder();
  }

  @override
  void onClose() {
    noteController.dispose(); // ⬅️ dispose controller
    super.onClose();
  }

  Future<void> _initOrder() async {
    try {
      if (_authProvider.currentUser == null) {
        throw Exception('User not authenticated');
      }
      await fetchAddresses();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mempersiapkan data pesanan',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Order init error: $e');
    }
  }

  Future<void> fetchAddresses() async {
    try {
      isLoadingAddress.value = true;

      final List<AddressModel> res = await _addressProvider.getUserAddresses(userId);

      addresses.value = res;

      if (addresses.isNotEmpty) {
        selectedAddress.value = addresses.first;
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat alamat');
      print('Fetch address error: $e');
    } finally {
      isLoadingAddress.value = false;
    }
  }

  void selectAddress(AddressModel address) {
    selectedAddress.value = address;
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

    if (selectedAddress.value == null) {
      Get.snackbar(
        'Alamat belum dipilih',
        'Silakan pilih alamat terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isSubmitting.value = true;

      final orderData = {
        'user_id': userId,
        'service_id': service.id,
        'address_id': selectedAddress.value!.id,
        'weight': weight.value,
        'total_price': totalPrice,
        'note': noteController.text, // ⬅️ ambil dari controller
        'status': OrderStatus.pending,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _orderProvider.createOrder(orderData);

      Get.back();

      Get.snackbar(
        'Berhasil',
        'Pesanan ${service.name} berhasil dibuat',
        snackPosition: SnackPosition.BOTTOM,
      );

      selectedAddress.value = null;
      weight.value = 1.0;
      noteController.clear(); // ⬅️ reset note
    } catch (e) {
      print('Submit order error: $e');
      Get.snackbar(
        'Gagal',
        'Gagal membuat pesanan',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
