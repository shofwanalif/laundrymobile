import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import '../controllers/add_address_controller.dart';
import '../../../core/theme/app_colors.dart';

class AddAddressView extends GetView<AddAddressController> {
  const AddAddressView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        // JUDUL DINAMIS: Cek apakah sedang edit atau tambah baru
        title: Obx(() => Text(
          controller.isEditMode.value ? 'Edit Alamat' : 'Tambah Alamat', 
          style: const TextStyle(fontWeight: FontWeight.bold)
        )),
        centerTitle: true,
        backgroundColor: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.6),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        final selected = controller.selectedLatLng.value;
        if (selected == null) return const Center(child: Text('Lokasi tidak tersedia'));

        return Stack(
          children: [
            // --- LAPISAN 1: PETA ---
            FlutterMap(
              mapController: controller.mapController,
              options: MapOptions(
                initialCenter: selected,
                initialZoom: 16,
                onTap: (_, point) => controller.updateMarkerPosition(point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.laundrymobile',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: selected,
                      width: 80,
                      height: 80,
                      child: const Icon(
                        Icons.location_on_rounded,
                        size: 45,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // --- LAPISAN 2: TOMBOL AKSI (Zoom & GPS) ---
            Positioned(
              right: 16,
              bottom: 340, // Disesuaikan agar pas di atas panel
              child: Column(
                children: [
                  _buildMapActionBtn(
                    icon: Icons.my_location_rounded,
                    onTap: controller.moveToCurrentLocation,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildMapActionBtn(
                    icon: Icons.add_rounded,
                    onTap: () => controller.mapController.move(
                        controller.mapController.camera.center, 
                        controller.mapController.camera.zoom + 1),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  _buildMapActionBtn(
                    icon: Icons.remove_rounded,
                    onTap: () => controller.mapController.move(
                        controller.mapController.camera.center, 
                        controller.mapController.camera.zoom - 1),
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            // --- LAPISAN 3: PANEL FORM ---
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SingleChildScrollView( // Tambahkan scroll agar aman di layar kecil
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                      const SizedBox(height: 20),
                      
                      // Input Label (Rumah/Kantor)
                      _buildInput(
                        hint: 'Label (Contoh: Rumah / Kantor)',
                        icon: Icons.bookmark_outline_rounded,
                        isDark: isDark,
                        textController: controller.labelTextController, // Gunakan controller
                        onChanged: (v) => controller.label.value = v,
                      ),
                      const SizedBox(height: 12),
                      
                      // Input Alamat Lengkap
                      _buildInput(
                        hint: 'Alamat Lengkap & Detail',
                        icon: Icons.home_work_outlined,
                        isDark: isDark,
                        maxLines: 2,
                        textController: controller.addressTextController, // Gunakan controller
                        onChanged: (v) => controller.address.value = v,
                      ),
                      const SizedBox(height: 20),

                      // Tombol Simpan / Perbarui
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: controller.isSaving.value ? null : controller.saveAddress,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: controller.isSaving.value
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(
                                  controller.isEditMode.value ? 'Perbarui Alamat' : 'Simpan Alamat', 
                                  style: const TextStyle(fontWeight: FontWeight.bold)
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMapActionBtn({required IconData icon, required VoidCallback onTap, required bool isDark}) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      color: isDark ? AppColors.darkSurface : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
      ),
    );
  }

  Widget _buildInput({
    required String hint, 
    required IconData icon, 
    required bool isDark, 
    required Function(String) onChanged, 
    required TextEditingController textController, // Tambahkan parameter controller
    int maxLines = 1
  }) {
    return TextField(
      controller: textController, // Hubungkan ke controller dari GetX
      onChanged: onChanged,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}