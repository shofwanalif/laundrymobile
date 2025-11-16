import 'package:get/get.dart';

import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/admin/bindings/admin_binding.dart';
import '../modules/admin/views/admin_views.dart';
import '../../middleware/auth_middleware.dart';
//import '../../middleware/admin_middleware.dart';
import '../../middleware/role_check_middleware.dart';
import '../modules/admin/bindings/services_binding.dart';
import '../modules/admin/views/service_list_view.dart';
import '../modules/admin/views/service_form_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomePage(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware(), RoleCheckMiddleware()],
    ),

    GetPage(
      name: Routes.ADMIN_DASHBOARD,
      page: () => const AdminDashboardView(),
      binding: AdminBinding(),
      middlewares: [AuthMiddleware(), RoleCheckMiddleware()],
    ),

    GetPage(
      name: _Paths.SERVICES_ADMIN,
      page: () => const ServicesListView(),
      binding: ServicesBinding(),
      middlewares: [AuthMiddleware(), RoleCheckMiddleware()],
    ),

    GetPage(
      name: _Paths.SERVICE_FORM,
      page: () => const ServiceFormView(),
      binding: ServicesBinding(),
      middlewares: [AuthMiddleware(), RoleCheckMiddleware()],
    ),

    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
  ];
}
