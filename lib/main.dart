import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:laundrymobile/app/data/providers/auth_provider.dart';
import 'package:laundrymobile/app/data/providers/services_provider.dart'; 
import 'package:laundrymobile/app/data/services/supabase_service.dart';
import 'package:laundrymobile/app/data/services/hive_service.dart';
import 'package:laundrymobile/app/data/services/theme_service.dart';
import 'package:laundrymobile/app/data/services/services_data_service.dart';
import 'package:laundrymobile/app/routes/app_pages.dart';
import 'package:laundrymobile/app/modules/auth/controllers/auth_controller.dart';
import 'package:laundrymobile/app/data/models/services_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Hive
    await Hive.initFlutter();
    Hive.registerAdapter(ServicesModelAdapter());
    
    await Get.putAsync(() => SupabaseService().init());
    
    Get.put(ServicesProvider()); 
    Get.put(AuthProvider());
    Get.put(AuthController());
    
    // Initialize HiveService
    await Get.putAsync(() => HiveService().init());
    
    // Initialize ServicesDataService terakhir (karena bergantung pada yang lain)
    await Get.putAsync(() => ServicesDataService().init());

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
      return ChangeNotifierProvider(
        create: (_) => ThemeService(),
        child: _buildMaterialApp(initialRoute: Routes.LOGIN),
      );
    }

    // Jika login, tunggu role loaded dulu
    return Obx(() {
      if (!authController.isRoleLoaded.value) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat...'),
                ],
              ),
            ),
          ),
        );
      }

      final initialRoute = authController.userRole.value == 'admin'
          ? Routes.ADMIN_DASHBOARD
          : Routes.HOME;

      debugPrint('🚀 Initial route: $initialRoute (role: ${authController.userRole.value})');

      return ChangeNotifierProvider(
        create: (_) => ThemeService(),
        child: _buildMaterialApp(initialRoute: initialRoute),
      );
    });
  }

  Widget _buildMaterialApp({required String initialRoute}) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: initialRoute,
          getPages: AppPages.routes,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeService.themeMode,
        );
      },
    );
  }
}