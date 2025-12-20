import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../my_orders/controllers/my_orders_controller.dart';
import '../../../core/order_status.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/app_strings.dart';
import 'package:intl/intl.dart';

class MyOrdersView extends GetView<MyOrdersController> {
  const MyOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Laundry Saya',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark
            ? AppColors.darkTextPrimary
            : AppColors.textPrimary,
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
          onRefresh: controller.fetchActiveOrders,
          color: AppColors.primary,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: 16,
            ),
            itemCount: controller.orders.length,
            itemBuilder: (_, index) {
              final order = controller.orders[index];
              return _buildOrderCard(order, screenWidth, isDark);
            },
          ),
        );
      }),
    );
  }

  Widget _buildOrderCard(order, double screenWidth, bool isDark) {
    final statusLabel = AppStrings().orderStatusLabel(order.status);
    final orderDate = DateFormat(
      'dd MMM yyyy, HH:mm',
      'id_ID',
    ).format(order.createdAt);
    final Color statusColor = _statusColor(order.status);

    final address = controller.addresses.firstWhereOrNull(
      (a) => a.id == order.addressId,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => {}, // Anda bisa arahkan ke halaman detail di sini
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- ICON STATUS ---
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.local_laundry_service_rounded,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 16),

              // --- INFO SECTION ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: ID & Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order #${order.id.substring(0, 6).toUpperCase()}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.04,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        _buildStatusBadge(statusLabel, statusColor, isDark),
                      ],
                    ),

                    // Tanggal
                    Text(
                      orderDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ALAMAT PENGAMBILAN / PENGANTARAN
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            address?.label ?? 'Alamat tidak tersedia',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (address != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 2),
                        child: Text(
                          address.address,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    // --- CATATAN (Jika ada) ---
                    if (order.note != null && order.note.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceVariant.withValues(
                                  alpha: 0.5,
                                )
                              : AppColors.surfaceVariant.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                          border: const Border(
                            left: BorderSide(
                              color: AppColors.primary,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.sticky_note_2_rounded,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                order.note,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const Divider(height: 24),

                    // --- INFO BERAT & HARGA ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildPriceInfo('Berat', '${order.weight} kg', isDark),
                        _buildPriceInfo(
                          'Total Bayar',
                          'Rp ${order.totalPrice}',
                          isDark,
                          isBold: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPriceInfo(
    String title,
    String value,
    bool isDark, {
    bool isBold = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold
                ? AppColors.primary
                : (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.washing:
        return Colors.cyan;
      case OrderStatus.completed:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmpty(double screenWidth, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: screenWidth * 0.2,
            color: AppColors.textTertiary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada pesanan aktif',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
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
          Icon(
            Icons.cloud_off_rounded,
            size: screenWidth * 0.15,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          const Text('Gagal memuat data pesanan'),
          TextButton(
            onPressed: controller.fetchActiveOrders,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
