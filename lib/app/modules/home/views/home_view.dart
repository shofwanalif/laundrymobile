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
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return Scaffold(
          backgroundColor: _getBackgroundColor(context),
          appBar: _buildAppBar(context, themeService),
          body: _buildBody(context),
          drawer: _buildDrawer(context),
        );
      },
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkBackground
        : AppColors.background;
  }

  AppBar _buildAppBar(BuildContext context, ThemeService themeService) {
    return AppBar(
      title: Text(
        'Layanan Laundry',
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkTextPrimary
              : AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.primaryDark
          : AppColors.primaryLight,
      elevation: 0.5,
      actions: [
        IconButton(
          icon: Icon(
            themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkTextPrimary
                : AppColors.textPrimary,
          ),
          onPressed: () => themeService.toggleTheme(),
        ),
        Obx(
          () => IconButton(
            icon: controller.isLoading.value
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  )
                : Icon(
                    Icons.refresh,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
            onPressed: controller.isLoading.value
                ? null
                : controller.refreshData,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.directions, color: Colors.greenAccent),
          tooltip: 'Ayo rute kami!',
          onPressed: () {
            controller.goToLocation();
          },
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          UserAccountsDrawerHeader(
            accountName: Text(
              'User',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              controller.userEmail ?? 'user@example.com',
              style: TextStyle(color: AppColors.white.withValues(alpha: 0.8)),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppColors.white,
              child: Icon(Icons.person, color: AppColors.primary, size: 40),
            ),
            decoration: BoxDecoration(gradient: AppColors.primaryGradient),
          ),

          // Menu Items
          ListTile(
            leading: Icon(Icons.home, color: AppColors.primary),
            title: const Text('Beranda'),
            onTap: () {
              Get.back();
            },
          ),

          ListTile(
            leading: Icon(Icons.shopping_cart, color: AppColors.primary),
            title: const Text('Laundry Saya'),
            onTap: () {
              Get.back();
              Get.toNamed(Routes.MY_ORDERS);
            },
          ),

          ListTile(
            leading: Icon(Icons.history, color: AppColors.primary),
            title: const Text('Riwayat'),
            onTap: () {
              Get.back();
              Get.toNamed(Routes.ORDERS_HISTORY);
            },
          ),

          ListTile(
            leading: Icon(Icons.settings, color: AppColors.primary),
            title: const Text('Pengaturan'),
            onTap: () {
              Get.back();
              // Navigate to settings if needed
            },
          ),

          const Divider(),

          // Logout Button
          ListTile(
            leading: Icon(Icons.logout, color: AppColors.error),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Get.back();
              controller.logout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return GetX<HomeController>(
      builder: (controller) {
        return Column(
          children: [
            // Offline Mode Indicator - Always check this condition
            if (controller.isOfflineMode.value)
              OfflineIndicator(onRetry: controller.refreshData),

            // Main Content
            Expanded(child: _buildContent(context)),
          ],
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return GetX<HomeController>(
      builder: (controller) {
        // Jika sedang loading dan tidak ada data
        if (controller.isLoading.value && controller.services.isEmpty) {
          return _buildLoadingWidget();
        }

        // Jika ada error dan tidak ada data cached
        if (controller.hasError.value && controller.services.isEmpty) {
          return _buildErrorWidget(context);
        }

        // Jika tidak ada data sama sekali
        if (!controller.hasData && !controller.isLoading.value) {
          return _buildEmptyWidget(context);
        }

        return ServiceList(onServiceTap: _onServiceTap);
      },
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Memuat layanan...'),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _getErrorMessage(controller.errorMessage.value),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: controller.refreshData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Coba Lagi'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Kembali'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_laundry_service,
              size: 64,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextTertiary
                  : AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Layanan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Saat ini belum ada layanan laundry yang tersedia\nSilakan coba lagi nanti',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Muat Ulang'),
            ),
          ],
        ),
      ),
    );
  }

  String _getErrorMessage(String error) {
    if (error.contains('connection') || error.contains('network')) {
      return 'Koneksi internet terputus. Pastikan perangkat Anda terhubung ke internet dan coba lagi.';
    } else if (error.contains('timeout')) {
      return 'Server membutuhkan waktu terlalu lama untuk merespons. Silakan coba lagi.';
    } else if (error.contains('Supabase') || error.contains('database')) {
      return 'Terjadi masalah dengan server. Tim kami sedang memperbaiki. Silakan coba lagi nanti.';
    } else {
      return 'Terjadi kesalahan tak terduga: $error';
    }
  }

  void _onServiceTap(ServiceModel service) {
    Get.toNamed(
      Routes.ORDER,
      arguments: service,
    );
  }
}
