import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../controllers/home_controller.dart';
import '../../../data/services/theme_service.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/service_list.dart';
import '../widgets/offline_indicator.dart';
import '../../../data/models/service_model.dart';
import '../../../routes/app_pages.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Mendapatkan informasi ukuran layar
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return Scaffold(
          backgroundColor: _getBackgroundColor(context),
          // Menggunakan PreferredSize agar bisa mengatur tinggi AppBar secara dinamis
          appBar: _buildAppBar(context, themeService, screenWidth),
          body: _buildBody(context, screenWidth, isTablet),
          drawer: _buildDrawer(context, screenWidth),
        );
      },
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkBackground
        : AppColors.background;
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ThemeService themeService,
    double screenWidth,
  ) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Layanan Laundry',
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.05,
            ),
          ),
          Text(
            'Bersih, Wangi, Cepat',
            style: TextStyle(
              color:
                  (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary)
                      .withValues(alpha: 0.7),
              fontSize: screenWidth * 0.03,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? null
              : LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
      ),
      actions: [
        _buildActionIcon(
          icon: themeService.isDarkMode
              ? Icons.light_mode_rounded
              : Icons.dark_mode_rounded,
          onPressed: () => themeService.toggleTheme(),
          context: context,
        ),
        Obx(
          () => _buildActionIcon(
            icon: controller.isLoading.value
                ? Icons.hourglass_empty
                : Icons.refresh_rounded,
            onPressed: controller.isLoading.value
                ? null
                : controller.refreshData,
            context: context,
            isLoading: controller.isLoading.value,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required VoidCallback? onPressed,
    required BuildContext context,
    bool isLoading = false,
    Color? iconColor,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                icon,
                color:
                    iconColor ??
                    (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary),
                size: 20,
              ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, double screenWidth) {
    return Drawer(
      width: screenWidth * 0.8, // Responsif: 80% dari lebar layar
      child: Container(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkBackground
            : AppColors.background,
        child: Column(
          children: [
            _buildCustomDrawerHeader(context),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _drawerItem(
                    Icons.home_rounded,
                    'Beranda',
                    () => Get.back(),
                    AppColors.primary,
                  ),
                  _drawerItem(Icons.shopping_bag_rounded, 'Laundry Saya', () {
                    Get.back();
                    controller.goToMyOrders();
                  }, AppColors.primary),
                  _drawerItem(Icons.history_rounded, 'Riwayat Pesanan', () {
                    Get.back();
                    controller.goToOrderHistory();
                  }, AppColors.primary),
                  _drawerItem(Icons.location_on, 'Alamat Saya', () {
                    Get.back();
                    controller.goToAddress();
                  }, AppColors.primary),
                  const Divider(indent: 20, endIndent: 20),
                  _drawerItem(Icons.logout_rounded, 'Keluar', () {
                    Get.back();
                    controller.logout();
                  }, AppColors.error),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomDrawerHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: AppColors.white.withValues(alpha: 0.2),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.white,
              child: Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: 35,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, ${controller.userName ?? 'Pelanggan'}!',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  controller.userEmail ?? 'user@example.com',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    IconData icon,
    String title,
    VoidCallback onTap,
    Color color,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  Widget _buildBody(BuildContext context, double screenWidth, bool isTablet) {
    return GetX<HomeController>(
      builder: (controller) {
        return Column(
          children: [
            if (controller.isOfflineMode.value)
              OfflineIndicator(onRetry: controller.refreshData),

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet
                      ? screenWidth * 0.1
                      : 16, // Padding lebih lebar di tablet
                ),
                child: _buildContent(context, screenWidth),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, double screenWidth) {
    if (controller.isLoading.value && controller.services.isEmpty) {
      return _buildLoadingWidget();
    }
    if (controller.hasError.value && controller.services.isEmpty) {
      return _buildErrorWidget(context, screenWidth);
    }
    if (!controller.hasData && !controller.isLoading.value) {
      return _buildEmptyWidget(context, screenWidth);
    }

    return RefreshIndicator(
      onRefresh: () => controller.refreshData(),
      child: ServiceList(onServiceTap: _onServiceTap),
    );
  }

  // State widgets (Error, Empty, Loading) sekarang menggunakan screenWidth untuk ukuran icon/font
  Widget _buildErrorWidget(BuildContext context, double screenWidth) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: screenWidth * 0.2,
              color: AppColors.error.withValues(alpha: 0.5),
            ),
            SizedBox(height: screenWidth * 0.05),
            Text(
              'Koneksi Terganggu',
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _getErrorMessage(controller.errorMessage.value),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: controller.refreshData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(BuildContext context, double screenWidth) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.layers_clear_rounded,
            size: screenWidth * 0.2,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 20),
          const Text(
            'Belum ada layanan tersedia',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child:
          CircularProgressIndicator.adaptive(), // Mengikuti style platform (iOS/Android)
    );
  }

  String _getErrorMessage(String error) {
    if (error.contains('connection') || error.contains('network')) {
      return 'Koneksi internet terputus. Pastikan perangkat Anda terhubung.';
    }
    return 'Terjadi kesalahan sistem. Silakan muat ulang halaman.';
  }

  void _onServiceTap(ServiceModel service) {
    Get.toNamed(Routes.ORDER, arguments: service);
  }
}
