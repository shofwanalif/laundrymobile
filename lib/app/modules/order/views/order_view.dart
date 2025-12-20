import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/order_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/address_model.dart';
import '../../../data/providers/address_provider.dart';

class OrderView extends GetView<OrderController> {
  const OrderView({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Buat Pesanan', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      ),
      bottomNavigationBar: _buildBottomBar(formatter, isDark),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 10),
        child: Column(
          children: [
            _buildServiceInfo(formatter, isDark),
            const SizedBox(height: 16),
            _buildAddressSection(isDark),
            const SizedBox(height: 16),
            _buildWeightSelector(isDark),
            const SizedBox(height: 16),
            _buildNoteField(isDark),
            const SizedBox(height: 32), // Extra space for bottom bar
          ],
        ),
      ),
    );
  }

  // ===================== SERVICE INFO =====================
  Widget _buildServiceInfo(NumberFormat formatter, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha:0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Layanan Terpilih',
                style: TextStyle(color: Colors.white.withValues(alpha:0.8), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            controller.service.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            controller.service.description,
            style: TextStyle(color: Colors.white.withValues(alpha:0.9), fontSize: 14),
          ),
          const Divider(color: Colors.white24, height: 24),
          Text(
            '${formatter.format(controller.service.pricePerKg)} / kg',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ===================== ADDRESS SECTION =====================
  Widget _buildAddressSection(bool isDark) {
    return _buildCardWrapper(
      isDark,
      title: 'Alamat Pengantaran',
      icon: Icons.map_rounded,
      child: Obx(() {
        final address = controller.selectedAddress.value;
        return Column(
          children: [
            if (address == null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.location_off_rounded, color: Colors.grey),
                    SizedBox(width: 12),
                    Text('Belum ada alamat dipilih', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            else
              _selectedAddressTile(address, isDark),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showAddressPicker,
                icon: const Icon(Icons.add_location_alt_rounded, size: 18),
                label: Text(address == null ? 'Pilih Alamat' : 'Ganti Alamat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha:0.1),
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _selectedAddressTile(AddressModel address, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha:0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha:0.2)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primary,
            radius: 18,
            child: Icon(Icons.home_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.label,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  address.address,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== WEIGHT SELECTOR =====================
  Widget _buildWeightSelector(bool isDark) {
    return _buildCardWrapper(
      isDark,
      title: 'Estimasi Berat Cucian',
      icon: Icons.scale_rounded,
      child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _weightBtn(Icons.remove_rounded, controller.decreaseWeight, isDark),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(
                      '${controller.weight.value.toStringAsFixed(1)}',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const Text('Kilogram', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              _weightBtn(Icons.add_rounded, controller.increaseWeight, isDark),
            ],
          )),
    );
  }

  Widget _weightBtn(IconData icon, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
    );
  }

  // ===================== NOTE FIELD =====================
  Widget _buildNoteField(bool isDark) {
    return _buildCardWrapper(
      isDark,
      title: 'Catatan Khusus',
      icon: Icons.edit_note_rounded,
      child: TextField(
        maxLines: 2,
        controller: controller.noteController,
        decoration: InputDecoration(
          hintText: 'Contoh: Jangan campur baju luntur...',
          fillColor: isDark ? AppColors.darkSurfaceVariant : Colors.grey[50],
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        onChanged: (value) => controller.note.value = value,
      ),
    );
  }

  // ===================== UTILS =====================
  Widget _buildCardWrapper(bool isDark, {required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  void _showAddressPicker() async {
    final AddressProvider addressProvider = Get.find();
    final addresses = await addressProvider.getUserAddresses(controller.userId);

    if (addresses.isEmpty) {
      Get.snackbar('Alamat Kosong', 'Silakan tambah alamat di profil terlebih dahulu',
          backgroundColor: AppColors.error, colorText: Colors.white);
      return;
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text('Pilih Alamat Pengiriman', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: addresses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, index) {
                  final address = addresses[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey[200]!)),
                    leading: const Icon(Icons.location_on, color: AppColors.primary),
                    title: Text(address.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(address.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () {
                      controller.selectAddress(address);
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ===================== BOTTOM BAR =====================
  Widget _buildBottomBar(NumberFormat formatter, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Obx(() {
          final total = controller.weight.value * controller.service.pricePerKg;
          return Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Pembayaran', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      formatter.format(total),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: controller.selectedAddress.value == null ? null : controller.submitOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    shadowColor: AppColors.primary.withValues(alpha:0.4),
                  ),
                  child: Text(
                    controller.selectedAddress.value == null ? 'Pilih Alamat' : 'Pesan Sekarang',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}