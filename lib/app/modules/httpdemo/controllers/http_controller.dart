import 'package:get/get.dart';
import '../../../data/models/laundry_service.dart';
import '../../../data/services/http_service.dart';

class HttpController extends GetxController {
  final HttpService _httpService = HttpService();

  final RxList<LaundryService> services = <LaundryService>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }

  Future<void> fetchServices() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _httpService.getAllServices();

      services.value = response;
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshServices() async {
    await fetchServices();
  }
}
