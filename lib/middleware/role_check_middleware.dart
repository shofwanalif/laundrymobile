import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../app/modules/auth/controllers/auth_controller.dart';
import '../app/data/providers/auth_provider.dart';
import '../app/routes/app_pages.dart';

class RoleCheckMiddleware extends GetMiddleware {
  @override
  int? get priority => 0;

  @override
  RouteSettings? redirect(String? route) {
    final authProvider = Get.find<AuthProvider>();

    // Jika tidak login, lewati
    if (!authProvider.isAuthenticated) {
      return null;
    }

    final authController = Get.find<AuthController>();

    // Tunggu sampai role selesai di-load
    // Gunakan ever() untuk reactive check
    if (!authController.isRoleLoaded.value) {
      // Tunda redirect, tunggu role loaded dulu
      ever(authController.isRoleLoaded, (loaded) {
        if (loaded) {
          _checkAndRedirect(authController.userRole.value, route);
        }
      });
      return null; // Biarkan route jalan dulu
    }

    // Jika sudah loaded, langsung cek
    return _checkAndRedirect(authController.userRole.value, route);
  }

  RouteSettings? _checkAndRedirect(String role, String? route) {
    if (role == 'admin' && route == Routes.HOME) {
      return const RouteSettings(name: Routes.ADMIN_DASHBOARD);
    } else if (role != 'admin' && route == Routes.ADMIN_DASHBOARD) {
      return const RouteSettings(name: Routes.HOME);
    }
    return null;
  }
}
