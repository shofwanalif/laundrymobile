import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/supabase_service.dart';

class CustomerProvider extends GetxService {
  final SupabaseService _supabase = Get.find();

  Future<List<Map<String, dynamic>>> getAllCustomers() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('id, name, phone, role')
          .eq('role', 'user')
          .order('name', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching customers: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCustomerStats(String customerId) async {
    try {
      final orders = await _supabase
          .from('orders')
          .select('id, total_price')
          .eq('user_id', customerId);

      final orderList = List<Map<String, dynamic>>.from(orders);

      int totalSpend = 0;
      for (var order in orderList) {
        if (order['total_price'] != null) {
          totalSpend += (order['total_price'] as num).toInt();
        }
      }

      return {'totalOrders': orderList.length, 'totalSpend': totalSpend};
    } catch (e) {
      debugPrint('Error fetching customer stats: $e');
      return {'totalOrders': 0, 'totalSpend': 0};
    }
  }

  Future<List<Map<String, dynamic>>> getCustomersWithStats() async {
    try {
      final customers = await getAllCustomers();

      // Fetch stats for each customer
      for (int i = 0; i < customers.length; i++) {
        final stats = await getCustomerStats(customers[i]['id']);
        customers[i]['totalOrders'] = stats['totalOrders'];
        customers[i]['totalSpend'] = stats['totalSpend'];
      }

      return customers;
    } catch (e) {
      debugPrint('Error fetching customers with stats: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getCustomerOrders(
    String customerId,
  ) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('*, services(*)')
          .eq('user_id', customerId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching customer orders: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> searchCustomers(String query) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('id, name, phone, role')
          .eq('role', 'user')
          .ilike('name', '%$query%')
          .order('name', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error searching customers: $e');
      rethrow;
    }
  }
}
