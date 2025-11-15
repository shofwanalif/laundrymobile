import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../app/modules/auth/controllers/auth_controller.dart';
import '../app/data/providers/auth_provider.dart';
import '../app/routes/app_pages.dart';

// class AdminMiddleware extends GetMiddleware {
//   @override
//   RouteSettings? redirect(String? route) {
//     // AMAN → pada tahap ini AuthController sudah dipanggil lewat initialBinding
//     final authController = Get.find<AuthController>();

//     if (authController.userRole.value != "admin") {
//       return const RouteSettings(name: Routes.HOME);
//     }
//     return null;
//   }
// }

class AdminMiddleware extends GetMiddleware {
  @override
  int? get priority => 1; // Jalankan setelah AuthMiddleware

  @override
  RouteSettings? redirect(String? route) {
    final authProvider = Get.find<AuthProvider>();
    final authController = Get.find<AuthController>();

    // Jika belum login, redirect ke login
    if (!authProvider.isAuthenticated) {
      return const RouteSettings(name: Routes.LOGIN);
    }

    // Jika role belum di-load, ambil dari Supabase dulu
    if (authController.userRole.value.isEmpty ||
        authController.userRole.value == 'user') {
      // Cek role dari database
      final userId = authProvider.currentUser?.id;
      if (userId != null) {
        authProvider.getUserRole(userId).then((role) {
          authController.userRole.value = role;

          // Jika bukan admin, redirect ke home
          if (role != 'admin') {
            Get.offAllNamed(Routes.HOME);
          }
        });
      }
    }

    // Jika sudah ada role dan bukan admin
    if (authController.userRole.value != 'admin') {
      return const RouteSettings(name: Routes.HOME);
    }

    return null;
  }
}
