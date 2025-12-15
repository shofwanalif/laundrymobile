import 'package:get/get.dart';
import 'package:flutter/material.dart';
//import 'package:laundrymobile/app/core/theme/app_colors.dart';
import '../controllers/admin_controller.dart';
import '../../../../app/modules/auth/controllers/auth_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../data/services/notification_handler.dart';

class AdminDashboardView extends GetView<AdminController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationHandler = NotificationHandler();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Get.find<AuthController>().logout(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDashboardCard(
              icon: Icons.cleaning_services,
              title: 'Manage Services',
              color: Colors.blue,
              onTap: () => Get.toNamed(Routes.SERVICES_ADMIN),
            ),
            _buildDashboardCard(
              icon: Icons.shopping_bag,
              title: 'Orders',
              color: Colors.green,
              onTap: () {
                notificationHandler.showNotification(
                  title: "Coming Soon",
                  body: "Fitur ini dalam proses pengembangan.",
                );
              },
            ),
            _buildDashboardCard(
              icon: Icons.people,
              title: 'Customers',
              color: Colors.orange,
              onTap: () {
                notificationHandler.showCustomSoundNotification();
              },
            ),
            _buildDashboardCard(
              icon: Icons.analytics,
              title: 'Reports',
              color: Colors.purple,
              onTap: () {
                // TODO: Navigate to reports
                Get.snackbar('Info', 'Reports feature coming soon');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
