import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/admin_order_controller.dart';
import '../widgets/order_card.dart';
import '../../../widgets/common/button.dart';

class ManageOrdersView extends GetView<AdminOrderController> {
  const ManageOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'List Order',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lihat semua order dari pelanggan',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // TabBar
            TabBar(
              controller: controller.tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              indicatorWeight: 3,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              tabs: controller.tabs.map((tab) {
                return Tab(text: tab['label'] as String);
              }).toList(),
            ),

            // TabBarView
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                children: controller.tabs.map((tab) {
                  return _buildOrderList();
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList() {
    return Obx(() {
      if (controller.isLoading.value && controller.orders.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.orders.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Tidak ada pesanan',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.fetchOrders,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.orders.length,
          itemBuilder: (context, index) {
            final order = controller.orders[index];
            final profile = order['profiles'] as Map<String, dynamic>?;

            return OrderCard(
              orderId:
                  'Order #${(order['id'] as String).substring(0, 8).toUpperCase()}',
              totalPayment: _formatPrice(order['total_price'] ?? 0),
              customerName: profile?['name'] ?? 'Unknown',
              onTap: () => _showOrderDetail(order),
              onMenuTap: () => _showOrderDetail(order),
            );
          },
        ),
      );
    });
  }

  String _formatPrice(dynamic price) {
    final numPrice = price is int ? price : int.tryParse(price.toString()) ?? 0;
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(numPrice);
  }

  void _showOrderDetail(Map<String, dynamic> order) {
    final service = order['services'] as Map<String, dynamic>?;
    final profile = order['profiles'] as Map<String, dynamic>?;
    final status = order['status'] as String? ?? 'pending';
    final createdAt = order['created_at'] != null
        ? DateTime.parse(order['created_at'])
        : DateTime.now();
    final nextStatuses = controller.getNextStatuses(status);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Detail Order',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Order Info
              _buildDetailItem(
                'Order ID',
                '#${(order['id'] as String).substring(0, 8).toUpperCase()}',
              ),
              _buildDetailItem('Pelanggan', profile?['name'] ?? 'Unknown'),
              _buildDetailItem('Telepon', profile?['phone'] ?? '-'),
              _buildDetailItem('Layanan', service?['name'] ?? '-'),
              _buildDetailItem('Berat', '${order['weight'] ?? 0} kg'),
              _buildDetailItem(
                'Total',
                _formatPrice(order['total_price'] ?? 0),
              ),
              _buildDetailItem(
                'Tanggal',
                DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(createdAt),
              ),
              if (order['note'] != null && order['note'].toString().isNotEmpty)
                _buildDetailItem('Catatan', order['note']),

              // Current Status
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    'Status: ',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: controller.getStatusColor(status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      controller.getStatusLabel(status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              if (nextStatuses.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Update Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: nextStatuses.map((newStatus) {
                    return StatusButton(
                      text: controller.getStatusLabel(newStatus),
                      backgroundColor: controller.getStatusColor(newStatus),
                      onPressed: () {
                        Get.back();
                        controller.updateOrderStatus(order['id'], newStatus);
                      },
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
