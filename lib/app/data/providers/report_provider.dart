import 'package:get/get.dart';
import '../services/supabase_service.dart';
import '../../core/order_status.dart';

class ReportProvider extends GetxService {
  final SupabaseService _supabase = Get.find();

  /// Get count of active orders (pending, processing, washing, completed)
  Future<int> getActiveOrdersCount() async {
    try {
      final response = await _supabase
          .from('orders')
          .select('id')
          .filter('status', 'in', '(${OrderStatus.activeStatuses.join(',')})');
      return (response as List).length;
    } catch (e) {
      throw Exception('Failed to get active orders count: $e');
    }
  }

  /// Get count of completed orders (picked_up only, excluding cancelled)
  Future<int> getCompletedOrdersCount() async {
    try {
      final response = await _supabase
          .from('orders')
          .select('id')
          .eq('status', OrderStatus.pickedUp);
      return (response as List).length;
    } catch (e) {
      throw Exception('Failed to get completed orders count: $e');
    }
  }

  /// Get daily report for a specific date
  Future<Map<String, dynamic>> getDailyReport(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('orders')
          .select('total_price, weight, status')
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String())
          .eq('status', OrderStatus.pickedUp);

      final orders = List<Map<String, dynamic>>.from(response);

      int totalRevenue = 0;
      double totalWeight = 0;
      int totalOrders = orders.length;

      for (final order in orders) {
        totalRevenue += (order['total_price'] as int?) ?? 0;
        totalWeight += ((order['weight'] ?? 0) as num).toDouble();
      }

      return {
        'totalRevenue': totalRevenue,
        'totalOrders': totalOrders,
        'totalWeight': totalWeight,
      };
    } catch (e) {
      throw Exception('Failed to get daily report: $e');
    }
  }

  /// Get monthly report for a specific month
  Future<Map<String, dynamic>> getMonthlyReport(int year, int month) async {
    try {
      final startOfMonth = DateTime(year, month, 1);
      final endOfMonth = DateTime(year, month + 1, 1);

      final response = await _supabase
          .from('orders')
          .select('total_price, weight, created_at, status')
          .gte('created_at', startOfMonth.toIso8601String())
          .lt('created_at', endOfMonth.toIso8601String())
          .eq('status', OrderStatus.pickedUp);

      final orders = List<Map<String, dynamic>>.from(response);

      int totalRevenue = 0;
      double totalWeight = 0;
      int totalOrders = orders.length;

      // Daily revenue for chart
      final Map<int, int> dailyRevenue = {};
      final daysInMonth = DateTime(year, month + 1, 0).day;
      for (int i = 1; i <= daysInMonth; i++) {
        dailyRevenue[i] = 0;
      }

      for (final order in orders) {
        final price = (order['total_price'] as int?) ?? 0;
        final weight = ((order['weight'] ?? 0) as num).toDouble();
        totalRevenue += price;
        totalWeight += weight;

        // Parse date for daily chart
        final createdAt = DateTime.parse(order['created_at']);
        final day = createdAt.day;
        dailyRevenue[day] = (dailyRevenue[day] ?? 0) + price;
      }

      return {
        'totalRevenue': totalRevenue,
        'totalOrders': totalOrders,
        'totalWeight': totalWeight,
        'dailyRevenue': dailyRevenue,
      };
    } catch (e) {
      throw Exception('Failed to get monthly report: $e');
    }
  }

  /// Get service popularity for a specific month
  Future<List<Map<String, dynamic>>> getServicePopularity(
    int year,
    int month,
  ) async {
    try {
      final startOfMonth = DateTime(year, month, 1);
      final endOfMonth = DateTime(year, month + 1, 1);

      final response = await _supabase
          .from('orders')
          .select('service_id, services(name)')
          .gte('created_at', startOfMonth.toIso8601String())
          .lt('created_at', endOfMonth.toIso8601String())
          .eq('status', OrderStatus.pickedUp);

      final orders = List<Map<String, dynamic>>.from(response);

      // Count orders per service
      final Map<String, Map<String, dynamic>> serviceCount = {};

      for (final order in orders) {
        final serviceId = order['service_id'] as String;
        final serviceName =
            (order['services'] as Map<String, dynamic>?)?['name'] ?? 'Unknown';

        if (serviceCount.containsKey(serviceId)) {
          serviceCount[serviceId]!['count'] =
              (serviceCount[serviceId]!['count'] as int) + 1;
        } else {
          serviceCount[serviceId] = {
            'serviceId': serviceId,
            'serviceName': serviceName,
            'count': 1,
          };
        }
      }

      // Convert to list and sort by count
      final result = serviceCount.values.toList()
        ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

      return result;
    } catch (e) {
      throw Exception('Failed to get service popularity: $e');
    }
  }
}
