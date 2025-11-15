import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../core/app_strings.dart';
import '../../../routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthProvider _authProvider = Get.find();

  final isLoading = false.obs;
  final userRole = 'user'.obs;
  final isRoleLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    _restoreUserRole();
  }

  Future<void> _restoreUserRole() async {
    final user = _authProvider.currentUser;
    if (user != null) {
      try {
        final role = await _authProvider.getUserRole(user.id);
        userRole.value = role;
        isRoleLoaded.value = true; // ← SET FLAG SETELAH LOAD
        debugPrint('✅ User role restored: $role');
      } catch (e) {
        debugPrint('❌ Error restoring role: $e');
        isRoleLoaded.value = true; // Tetap set true meskipun error
      }
    } else {
      isRoleLoaded.value = true;
    }
  }

  //Login
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      // 1. Login
      final response = await _authProvider.login(email.trim(), password);

      // 2. Ambil ID user dari session
      final userId = response.user?.id;
      if (userId == null) {
        throw Exception("User ID not found after login");
      }

      // 3. Ambil role dari Supabase
      final role = await _authProvider.getUserRole(userId);

      // 4. Simpan role
      userRole.value = role;

      Get.snackbar(
        'Success!',
        AppStrings.loginSuccess,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // 5. Redirect berdasarkan role
      if (role == 'admin') {
        Get.offAllNamed(Routes.ADMIN_DASHBOARD);
      } else {
        Get.offAllNamed(Routes.HOME);
      }
    } catch (e) {
      Get.snackbar(
        'Error!',
        '${AppStrings.loginFailed}: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  //Register
  Future<void> register(String email, String password) async {
    isLoading.value = true;
    try {
      await _authProvider.register(email.trim(), password);
      Get.snackbar(
        'Succes!',
        AppStrings.registerSuccess,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.closeAllSnackbars();
      Get.until((route) => route.settings.name == Routes.LOGIN);
    } catch (e) {
      Get.snackbar(
        'Error!',
        '${AppStrings.registerFailed} : ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  //Logout
  Future<void> logout() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text(AppStrings.logout),
        content: const Text(AppStrings.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authProvider.logout();
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  void goToRegister() {
    Get.toNamed(Routes.REGISTER);
  }

  void goToLogin() {
    Get.back();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.pleaseEnterEmail;
    }
    if (!value.contains('@')) {
      return AppStrings.pleaseEnterValidEmail;
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.pleaseEnterPassword;
    }
    if (value.length < 6) {
      return AppStrings.passwordMinLength;
    }
    return null;
  }

  String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return AppStrings.pleaseConfirmPassword;
    }
    if (value != password) {
      return AppStrings.passwordsDoNotMatch;
    }
    return null;
  }
}
