import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/service_model.dart';

class HiveService extends GetxService {
  static const String _servicesBox = 'services_box';
  late Box<ServiceModel> _servicesBoxInstance;

  Future<HiveService> init() async {
    _servicesBoxInstance = await Hive.openBox<ServiceModel>(_servicesBox);
    return this;
  }

  // Save services to cache
  Future<void> cacheServices(List<ServiceModel> services) async {
    await _servicesBoxInstance.clear();
    for (final service in services) {
      if (service.id != null) {
        await _servicesBoxInstance.put(service.id, service);
      }
    }
  }

  // Get cached services
  List<ServiceModel> getCachedServices() {
    return _servicesBoxInstance.values.toList();
  }

  // Check if cache exists
  bool hasCachedServices() {
    return _servicesBoxInstance.isNotEmpty;
  }

  // Clear cache
  Future<void> clearCache() async {
    await _servicesBoxInstance.clear();
  }

  // Get specific service by id
  ServiceModel? getServiceById(int id) {
    return _servicesBoxInstance.get(id);
  }

  @override
  void onClose() {
    _servicesBoxInstance.close();
    super.onClose();
  }
}