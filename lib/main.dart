import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laundrymobile/app/data/providers/auth_provider.dart';
import 'package:laundrymobile/app/data/services/supabase_service.dart';
import 'app/routes/app_pages.dart';
//import 'app/modules/auth/bindings/auth_binding.dart';
import 'app/modules/auth/controllers/auth_controller.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   try {
//     await Get.putAsync(() => SupabaseService().init());
//     Get.put(AuthProvider());
//     Get.put(AuthController());

//     runApp(const MyApp());
//   } catch (e, stackTrace) {
//     if (kDebugMode) {
//       debugPrint('❌ Error during initialization:');
//       debugPrint(e.toString());
//       debugPrint(stackTrace.toString());
//     }
//   }
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Get.find<AuthProvider>();

//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       initialRoute: authProvider.isAuthenticated ? Routes.HOME : Routes.LOGIN,
//       initialBinding: AuthBinding(),
//       getPages: AppPages.routes,
//     );
//   }
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Get.putAsync(() => SupabaseService().init());
    Get.put(AuthProvider());
    Get.put(AuthController());

    runApp(const MyApp());
  } catch (e, stackTrace) {
    if (kDebugMode) {
      debugPrint('❌ Error during initialization:');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Get.find<AuthProvider>();
    final authController = Get.find<AuthController>();

    // Jika tidak login, langsung ke login
    if (!authProvider.isAuthenticated) {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.LOGIN,
        getPages: AppPages.routes,
      );
    }

    // Jika login, tunggu role loaded dulu
    return Obx(() {
      // Tampilkan loading sampai role selesai di-fetch
      if (!authController.isRoleLoaded.value) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
        );
      }

      // Setelah role loaded, tentukan initial route
      final initialRoute = authController.userRole.value == 'admin'
          ? Routes.ADMIN_DASHBOARD
          : Routes.HOME;

      debugPrint(
        '🚀 Initial route: $initialRoute (role: ${authController.userRole.value})',
      );

      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: initialRoute,
        getPages: AppPages.routes,
      );
    });
  }
}
