import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/orders_history_controller.dart';
import '../../../core/order_status.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/app_strings.dart';

class OrdersHistoryView extends GetView<OrdersHistoryController> {
  const OrdersHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Laundry'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hasError.value) {
          return _buildError();
        }

        if (controller.orders.isEmpty) {
          return _buildEmpty();
        }

        return RefreshIndicator(
          onRefresh: controller.fetchOrderHistory,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.orders.length,
            itemBuilder: (_, index) {
              final order = controller.orders[index];
              return _buildOrderCard(order);
            },
          ),
        );
      }),
    );
  }

  Widget _buildOrderCard(order) {
    final statusLabel = AppStrings().orderStatusLabel(order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: const Icon(Icons.local_laundry_service),
        ),
        title: Text(
          'Order #${order.id.substring(0, 6)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Berat: ${order.weight} kg'),
            const SizedBox(height: 2),
            Text('Total: Rp ${order.totalPrice}'),
            const SizedBox(height: 4),
            Chip(
              label: Text(statusLabel),
              backgroundColor: _statusColor(order.status),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // NEXT: Order detail / tracking
        },
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange.shade100;
      case OrderStatus.processing:
        return Colors.blue.shade100;
      case OrderStatus.washing:
        return Colors.purple.shade100;
      case OrderStatus.completed:
        return Colors.green.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Widget _buildEmpty() {
    return const Center(
      child: Text(
        'Belum ada riwayat pemesanan',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          const Text('Gagal memuat pesanan'),
        ],
      ),
    );
  }
}
