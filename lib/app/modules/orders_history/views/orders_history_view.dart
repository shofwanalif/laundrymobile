import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/orders_history_controller.dart';
import '../../../core/order_status.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/app_strings.dart';
import 'package:intl/intl.dart';

class OrdersHistoryView extends GetView<OrdersHistoryController> {
  const OrdersHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Riwayat Laundry', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (controller.hasError.value) {
          return _buildError(screenWidth, isDark);
        }

        if (controller.orders.isEmpty) {
          return _buildEmpty(screenWidth, isDark);
        }

        return RefreshIndicator(
          onRefresh: controller.fetchOrderHistory,
          color: AppColors.primary,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, 
              vertical: 16
            ),
            itemCount: controller.orders.length,
            itemBuilder: (_, index) {
              final order = controller.orders[index];
              return _buildHistoryCard(order, screenWidth, isDark);
            },
          ),
        );
      }),
    );
  }

  Widget _buildHistoryCard(order, double screenWidth, bool isDark) {
    final statusLabel = AppStrings().orderStatusLabel(order.status);
    final orderDate = DateFormat('dd MMMM yyyy', 'id_ID').format(order.createdAt);
    final Color statusColor = _statusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkSeparator.withOpacity(0.5) : AppColors.separatorLight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => {}, // Navigate to detail
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Ikon Status Arsip
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        order.status == OrderStatus.completed 
                            ? Icons.check_circle_rounded 
                            : Icons.history_rounded, 
                        color: statusColor, 
                        size: 20
                      ),
                    ),
                    const SizedBox(width: 12),
                    // ID & Tanggal
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${order.id.substring(0, 6).toUpperCase()}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            orderDate,
                            style: TextStyle(
                              fontSize: 12, 
                              color: isDark ? AppColors.darkTextTertiary : AppColors.textSecondary
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(statusLabel, statusColor, isDark),
                  ],
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),

                // Baris Info Berat & Harga
                Row(
                  children: [
                    _buildInfoItem(Icons.scale_outlined, '${order.weight} kg', isDark),
                    const SizedBox(width: 24),
                    _buildInfoItem(Icons.payments_outlined, 'Rp ${order.totalPrice}', isDark, isPrimary: true),
                  ],
                ),

                // Catatan (jika ada)
                if (order.note != null && order.note.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Catatan: ${order.note}',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: isDark ? AppColors.darkTextTertiary : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color, 
          fontSize: 10, 
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, bool isDark, {bool isPrimary = false}) {
    return Row(
      children: [
        Icon(
          icon, 
          size: 16, 
          color: isPrimary ? AppColors.primary : (isDark ? AppColors.darkTextTertiary : AppColors.textSecondary)
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
            color: isPrimary 
                ? AppColors.primary 
                : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case OrderStatus.completed:
        return Colors.teal; // Hijau tenang untuk riwayat selesai
      case OrderStatus.cancelled:
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildEmpty(double screenWidth, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off_rounded, size: 80, color: AppColors.textTertiary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'Belum ada riwayat pesanan', 
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              fontWeight: FontWeight.w500
            )
          ),
        ],
      ),
    );
  }

  Widget _buildError(double screenWidth, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 60, color: AppColors.error),
          const SizedBox(height: 16),
          const Text('Gagal memuat riwayat'),
          TextButton(onPressed: controller.fetchOrderHistory, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }
}