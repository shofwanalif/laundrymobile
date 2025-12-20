import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickalert/quickalert.dart';
import '../../../data/providers/order_provider.dart';
import '../../../core/order_status.dart';

class AdminOrderController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final OrderProvider _orderProvider = Get.find();

  late TabController tabController;

  final orders = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final selectedTabIndex = 0.obs;

  // Tab labels
  final tabs = [
    {'label': 'Semua', 'status': 'all'},
    {'label': 'Pending', 'status': OrderStatus.pending},
    {'label': 'Proses', 'status': OrderStatus.processing},
    {'label': 'Cuci', 'status': OrderStatus.washing},
    {'label': 'Selesai', 'status': OrderStatus.completed},
    {'label': 'Riwayat', 'status': 'history'},
  ];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabs.length, vsync: this);
    tabController.addListener(_onTabChanged);
    fetchOrders();
  }

  @override
  void onClose() {
    tabController.removeListener(_onTabChanged);
    tabController.dispose();
    super.onClose();
  }

  void _onTabChanged() {
    if (!tabController.indexIsChanging) {
      selectedTabIndex.value = tabController.index;
      fetchOrders();
    }
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;

      final status = tabs[selectedTabIndex.value]['status'] as String;

      List<Map<String, dynamic>> result;

      if (status == 'all') {
        result = await _orderProvider.getAllOrders();
      } else if (status == 'history') {
        result = await _orderProvider.getHistoryOrders();
      } else {
        result = await _orderProvider.getOrdersByStatus(status);
      }

      orders.value = result;
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      isLoading.value = true;
      await _orderProvider.updateOrderStatus(
        orderId: orderId,
        status: newStatus,
      );

      await fetchOrders();

      final context = Get.context;
      if (context != null && context.mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Sukses',
          text: 'Status order berhasil diperbarui',
        );
      }
    } catch (e) {
      debugPrint('Error updating order status: $e');
      final context = Get.context;
      if (context != null && context.mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Gagal',
          text: 'Gagal memperbarui status: $e',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Get next available statuses for an order
  List<String> getNextStatuses(String currentStatus) {
    switch (currentStatus) {
      case OrderStatus.pending:
        return [OrderStatus.processing, OrderStatus.cancelled];
      case OrderStatus.processing:
        return [OrderStatus.washing, OrderStatus.cancelled];
      case OrderStatus.washing:
        return [OrderStatus.completed, OrderStatus.cancelled];
      case OrderStatus.completed:
        return [OrderStatus.pickedUp];
      default:
        return [];
    }
  }

  String getStatusLabel(String status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Diproses';
      case OrderStatus.washing:
        return 'Dicuci';
      case OrderStatus.completed:
        return 'Selesai';
      case OrderStatus.pickedUp:
        return 'Diambil';
      case OrderStatus.cancelled:
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.washing:
        return Colors.indigo;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.pickedUp:
        return Colors.teal;
      case OrderStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.pending;
      case OrderStatus.processing:
        return Icons.hourglass_top;
      case OrderStatus.washing:
        return Icons.local_laundry_service;
      case OrderStatus.completed:
        return Icons.check_circle;
      case OrderStatus.pickedUp:
        return Icons.shopping_bag;
      case OrderStatus.cancelled:
        return Icons.cancel;
      default:
        return Icons.circle;
    }
  }
}
