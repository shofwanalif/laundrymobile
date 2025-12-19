import 'package:get/get.dart';

import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/order/bindings/order_binding.dart';
import '../modules/order/views/order_view.dart';
import '../modules/my_orders/bindings/my_orders_binding.dart';
import '../modules/my_orders/views/my_orders_view.dart';
import '../modules/orders_history/bindings/orders_history_binding.dart';
import '../modules/orders_history/views/orders_history_view.dart';
import '../modules/admin/bindings/admin_binding.dart';
import '../modules/admin/views/admin_views.dart';
import '../../middleware/auth_middleware.dart';
import '../../middleware/role_check_middleware.dart';
import '../modules/admin/bindings/services_binding.dart';
import '../modules/admin/views/service_list_view.dart';
import '../modules/location/bindings/location_binding.dart';
import '../modules/location/views/location_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware(), RoleCheckMiddleware()],
    ),

    GetPage(
      name: _Paths.ORDER,
      page: () => const OrderView(),
      binding: OrderBinding(),
      middlewares: [AuthMiddleware(), RoleCheckMiddleware()],
    ),

    GetPage(
      name: _Paths.MY_ORDERS,
      page: () => const MyOrdersView(),
      binding: MyOrdersBinding(),
      middlewares: [AuthMiddleware(), RoleCheckMiddleware()],
    ),

    GetPage(
      name: _Paths.ORDERS_HISTORY,
      page: () => const OrdersHistoryView(),
      binding: OrdersHistoryBinding(),
      middlewares: [AuthMiddleware(), RoleCheckMiddleware()],
    ),

    GetPage(
      name: _Paths.ADMIN_DASHBOARD,
      page: () => const AdminDashboardView(),
      binding: AdminBinding(),
      middlewares: [AuthMiddleware(), RoleCheckMiddleware()],
    ),

    GetPage(
      name: _Paths.LOCATION,
      page: () => const LocationView(),
      binding: LocationBinding(),
      middlewares: [AuthMiddleware(), RoleCheckMiddleware()],
    ),

    GetPage(
      name: _Paths.SERVICES_ADMIN,
      page: () => const ServicesListView(),
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
