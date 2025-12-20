import 'package:get/get.dart';
import '../services/supabase_service.dart';
import '../../core/order_status.dart';

class OrderProvider extends GetxService {
  final SupabaseService _supabase = Get.find();

  // ===================== USER =====================

  /// CREATE ORDER (user)
  Future<void> createOrder(Map<String, dynamic> data) async {
    try {
      await _supabase.from('orders').insert(data);
    } catch (e) {
      throw Exception('Create order failed: $e');
    }
  }

  /// 🔄 ORDER BERJALAN (user)
  Future<List<Map<String, dynamic>>> getActiveOrders(String userId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('*, services(*)')
          .eq('user_id', userId)
          .filter(
            'status',
            'not.in',
            '(${OrderStatus.historyStatuses.join(',')})',
          )
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Fetch active orders failed: $e');
    }
  }

  /// 📜 RIWAYAT ORDER (user)
  Future<List<Map<String, dynamic>>> getOrderHistory(String userId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('*, services(*)')
          .eq('user_id', userId)
          .filter('status', 'in', '(${OrderStatus.historyStatuses.join(',')})')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Fetch order history failed: $e');
    }
  }

  // Admin

  /// GET ALL ORDERS (admin)
  Future<List<Map<String, dynamic>>> getAllOrders() async {
    try {
      final response = await _supabase
          .from('orders')
          .select('*, services(*)')
          .order('created_at', ascending: false);

      // Fetch user profiles for each order
      final orders = List<Map<String, dynamic>>.from(response);
      for (int i = 0; i < orders.length; i++) {
        final userId = orders[i]['user_id'];
        if (userId != null) {
          try {
            final profile = await _supabase
                .from('profiles')
                .select('name, phone')
                .eq('id', userId)
                .maybeSingle();
            orders[i]['profiles'] = profile;
          } catch (_) {
            orders[i]['profiles'] = null;
          }
        }
      }
      return orders;
    } catch (e) {
      throw Exception('Fetch all orders failed: $e');
    }
  }

  /// GET ORDERS BY STATUS (admin)
  Future<List<Map<String, dynamic>>> getOrdersByStatus(String status) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('*, services(*)')
          .eq('status', status)
          .order('created_at', ascending: false);

      // Fetch user profiles for each order
      final orders = List<Map<String, dynamic>>.from(response);
      for (int i = 0; i < orders.length; i++) {
        final userId = orders[i]['user_id'];
        if (userId != null) {
          try {
            final profile = await _supabase
                .from('profiles')
                .select('name, phone')
                .eq('id', userId)
                .maybeSingle();
            orders[i]['profiles'] = profile;
          } catch (_) {
            orders[i]['profiles'] = null;
          }
        }
      }
      return orders;
    } catch (e) {
      throw Exception('Fetch orders by status failed: $e');
    }
  }

  /// GET HISTORY ORDERS (admin) - picked_up & cancelled
  Future<List<Map<String, dynamic>>> getHistoryOrders() async {
    try {
      final response = await _supabase
          .from('orders')
          .select('*, services(*)')
          .filter('status', 'in', '(${OrderStatus.historyStatuses.join(',')})')
          .order('created_at', ascending: false);

      // Fetch user profiles for each order
      final orders = List<Map<String, dynamic>>.from(response);
      for (int i = 0; i < orders.length; i++) {
        final userId = orders[i]['user_id'];
        if (userId != null) {
          try {
            final profile = await _supabase
                .from('profiles')
                .select('name, phone')
                .eq('id', userId)
                .maybeSingle();
            orders[i]['profiles'] = profile;
          } catch (_) {
            orders[i]['profiles'] = null;
          }
        }
      }
      return orders;
    } catch (e) {
      throw Exception('Fetch history orders failed: $e');
    }
  }

  /// UPDATE STATUS ORDER (admin)
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    if (!OrderStatus.activeStatuses.contains(status) &&
        !OrderStatus.historyStatuses.contains(status)) {
      throw Exception('Invalid order status');
    }

    try {
      await _supabase
          .from('orders')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);
    } catch (e) {
      throw Exception('Update order status failed: $e');
    }
  }

  /// UPDATE PRICE (admin, jika berat berubah)
  Future<void> updateOrderPrice({
    required String orderId,
    required double weightKg,
    required int totalPrice,
  }) async {
    try {
      await _supabase
          .from('orders')
          .update({
            'weight_kg': weightKg,
            'total_price': totalPrice,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);
    } catch (e) {
      throw Exception('Update order price failed: $e');
    }
  }

  Future<void> deleteOrder(String orderId) async {
    await updateOrderStatus(orderId: orderId, status: OrderStatus.cancelled);
  }

  // ===================== SHARED =====================

  /// GET ORDER BY ID (detail)
  Future<Map<String, dynamic>?> getOrderById(String orderId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('*, services(*)')
          .eq('id', orderId)
          .single();

      return response;
    } catch (_) {
      return null;
    }
  }
}
