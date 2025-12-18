import 'package:get/get.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/services/supabase_service.dart';

class AdminController extends GetxController {
  final AuthProvider _authProvider = Get.find<AuthProvider>();
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  final userName = 'Admin'.obs;

  final totalCustomer = 0.obs;
  final totalService = 0.obs;
  final totalOrder = 0.obs;
  final totalRevenue = 0.obs;

  String get userEmail => _authProvider.currentUser?.email ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchUserName();
    fetchDashboardStats();
  }

  Future<void> fetchUserName() async {
    try {
      final userId = _authProvider.currentUser?.id;
      if (userId != null) {
        final name = await _authProvider.getUserName(userId);
        userName.value = name;
      }
    } catch (e) {
      userName.value = 'Admin';
    }
  }

  Future<void> fetchDashboardStats() async {
    try {
      final customers = await _supabaseService.client
          .from('profiles')
          .select('id')
          .eq('role', 'user');
      totalCustomer.value = customers.length;

      final services = await _supabaseService.client
          .from('services')
          .select('id');
      totalService.value = services.length;

      // Total orders (placeholder - tabel belum ada)
      // final orders = await _supabaseService.client.from('orders').select('id');
      // totalOrder.value = orders.length;
      totalOrder.value = 0;

      // Total revenue (placeholder - tabel belum ada)
      totalRevenue.value = 0;
    } catch (e) {
      // Handle error silently
    }
  }
}
