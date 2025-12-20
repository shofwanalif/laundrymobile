import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../controllers/admin_controller.dart';
import '../../../../app/modules/auth/controllers/auth_controller.dart';
import '../../../routes/app_pages.dart';
import '../widgets/card_list.dart';
import '../widgets/dashboard_card.dart';

class AdminDashboardView extends GetView<AdminController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        title: const Text(
          "Dashboard",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: PopupMenuButton<String>(
              offset: const Offset(0, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                if (value == 'logout') {
                  Get.find<AuthController>().logout();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => Text(
                          controller.userName.value,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.userEmail,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red, size: 20),
                      SizedBox(width: 10),
                      Text('Logout', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: Colors.lightBlueAccent,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Dashboard Cards Wrap
            Obx(() {
              final cardWidth = (MediaQuery.of(context).size.width - 44) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: DashboardCard(
                      title: 'Total Pelanggan',
                      subtitle: '${controller.totalCustomer.value} Customer',
                      icon: Icons.people,
                      color: const Color(0xFFE91E63),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: DashboardCard(
                      title: 'Total Layanan',
                      subtitle: '${controller.totalService.value} Services',
                      icon: Icons.dashboard,
                      color: const Color(0xFFFF7043),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: DashboardCard(
                      title: 'Total Order',
                      subtitle: '${controller.totalOrder.value} Orders',
                      icon: Icons.shopping_cart,
                      color: const Color(0xFFEC407A),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: DashboardCard(
                      title: 'Pendapatan',
                      subtitle: 'Rp ${controller.totalRevenue.value}',
                      icon: Icons.attach_money,
                      color: const Color(0xFF66BB6A),
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 24),

            const Text(
              "Menu",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            CardList(
              text: "Manage Service",
              description: "Manage all service",
              icon: Icons.dashboard,
              iconColor: Colors.blue,
              onPressed: () => Get.toNamed(Routes.SERVICES_ADMIN),
            ),

            const SizedBox(height: 16),

            CardList(
              text: "Manage Customer",
              description: "Manage all Customer",
              icon: Icons.person,
              iconColor: Colors.blue,
              onPressed: () {
                Get.toNamed(Routes.CUSTOMERS_ADMIN);
              },
            ),

            const SizedBox(height: 16),

            CardList(
              text: "Manage Order",
              description: "Kelola semua pesanan",
              icon: Icons.shopping_cart,
              iconColor: Colors.blue,
              onPressed: () => Get.toNamed(Routes.ORDERS_ADMIN),
            ),

            const SizedBox(height: 16),

            CardList(
              text: "Laporan",
              description: "Manage all Reports",
              icon: Icons.bar_chart,
              iconColor: Colors.blue,
              onPressed: () {
                Get.snackbar("Info", "Manage Notification");
              },
            ),
          ],
        ),
      ),
    );
  }
}
