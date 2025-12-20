import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/providers/customer_provider.dart';

class CustomerController extends GetxController {
  final CustomerProvider _customerProvider = Get.find();

  final customers = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  // For search debouncing
  final _searchController = TextEditingController();
  TextEditingController get searchController => _searchController;

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
  }

  @override
  void onClose() {
    _searchController.dispose();
    super.onClose();
  }

  /// Fetch all customers with their stats
  Future<void> fetchCustomers() async {
    try {
      isLoading.value = true;
      final result = await _customerProvider.getCustomersWithStats();
      customers.value = result;
    } catch (e) {
      debugPrint('Error fetching customers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Search customers by name
  Future<void> searchCustomers(String query) async {
    searchQuery.value = query;

    if (query.isEmpty) {
      await fetchCustomers();
      return;
    }

    try {
      isLoading.value = true;
      final result = await _customerProvider.searchCustomers(query);

      // Fetch stats for searched customers
      for (int i = 0; i < result.length; i++) {
        final stats = await _customerProvider.getCustomerStats(result[i]['id']);
        result[i]['totalOrders'] = stats['totalOrders'];
        result[i]['totalSpend'] = stats['totalSpend'];
      }

      customers.value = result;
    } catch (e) {
      debugPrint('Error searching customers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get customer orders for detail view
  Future<List<Map<String, dynamic>>> getCustomerOrders(
    String customerId,
  ) async {
    try {
      return await _customerProvider.getCustomerOrders(customerId);
    } catch (e) {
      debugPrint('Error fetching customer orders: $e');
      return [];
    }
  }

  /// Format price to Indonesian Rupiah
  String formatPrice(dynamic price) {
    final numPrice = price is int ? price : int.tryParse(price.toString()) ?? 0;
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(numPrice);
  }

  /// Clear search
  void clearSearch() {
    _searchController.clear();
    searchQuery.value = '';
    fetchCustomers();
  }
}
