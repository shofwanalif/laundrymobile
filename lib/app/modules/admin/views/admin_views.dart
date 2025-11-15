import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:laundrymobile/app/core/theme/app_colors.dart';
import '../controllers/admin_controller.dart';
import '../../../../app/modules/auth/controllers/auth_controller.dart';

class AdminDashboardView extends GetView<AdminController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard"), centerTitle: true),
      body: ListView(
        children: [
          Text("Selamat datang Admin!", style: TextStyle(fontSize: 20)),
          ElevatedButton(
            onPressed: () => Get.find<AuthController>().logout(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text("Logout", style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }
}
