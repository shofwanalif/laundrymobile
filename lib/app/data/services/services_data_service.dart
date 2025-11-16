import 'package:get/get.dart';
import '../models/services_model.dart';
import '../providers/services_provider.dart';
import 'hive_service.dart';

class ServicesDataService extends GetxService {
  final ServicesProvider _servicesProvider = Get.find<ServicesProvider>();
  final HiveService _hiveService = Get.find<HiveService>();

  Future<ServicesDataService> init() async {
    return this;
  }

  // Get services with cache strategy
  Future<List<ServicesModel>> getServices() async {
    try {
      // Try to fetch from Supabase
      final services = await _servicesProvider.getServices();
      // Cache the results
      await _hiveService.cacheServices(services);
      return services;
    } catch (e) {
      // If online fails, try cache
      if (_hiveService.hasCachedServices()) {
        return _hiveService.getCachedServices();
      }
      rethrow;
    }
  }

  // Get cached services only
  List<ServicesModel> getCachedServices() {
    return _hiveService.getCachedServices();
  }

  // Check if cache exists
  bool hasCachedData() {
    return _hiveService.hasCachedServices();
  }

  // Refresh data
  Future<List<ServicesModel>> refreshData() {
    return getServices();
  }
}