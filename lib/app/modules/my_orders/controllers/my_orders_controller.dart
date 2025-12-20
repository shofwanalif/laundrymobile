import 'package:get/get.dart';
import '../../../data/providers/order_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/address_provider.dart'; 
import '../../../data/models/order_model.dart';
import '../../../data/models/address_model.dart'; 

class MyOrdersController extends GetxController {
  final OrderProvider _orderProvider = Get.find();
  final AuthProvider _authProvider = Get.find();
  final AddressProvider _addressProvider = Get.find(); 

  final orders = <OrderModel>[].obs;
  final addresses = <AddressModel>[].obs; 
  
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  String? get userId => _authProvider.currentUser?.id;

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  Future<void> refreshData() async {
    if (userId == null) {
      hasError.value = true;
      errorMessage.value = 'User belum login';
      return;
    }

    try {
      isLoading.value = true;
      hasError.value = false;

      final results = await Future.wait([
        _orderProvider.getActiveOrders(userId!),
        _addressProvider.getUserAddresses(userId!),
      ]);

      final List<dynamic> orderResponse = results[0];
      orders.assignAll(
        orderResponse.map((e) => OrderModel.fromMap(e)).toList(),
      );

      final List<AddressModel> addressResponse = results[1] as List<AddressModel>;
      addresses.assignAll(addressResponse);

    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Gagal memuat data pesanan';
      print('Error MyOrdersController: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchActiveOrders() => refreshData();
}