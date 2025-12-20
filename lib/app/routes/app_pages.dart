import 'package:get/get.dart';
import 'package:laundrymobile/app/modules/address/bindings/address_binding.dart';
import 'package:laundrymobile/app/modules/address/views/address_view.dart';

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
import '../modules/admin/bindings/admin_order_binding.dart';
import '../modules/admin/views/manage_orders.dart';
import '../modules/admin/bindings/customer_binding.dart';
import '../modules/admin/views/manage_customers_view.dart';
import '../modules/add_address/bindings/add_address_binding.dart';
import '../modules/add_address/views/add_address_view.dart';

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
      name: _Paths.ADDRESS,
      page: () => const AddressView(),
      binding: AddressBinding(),
      middlewares: [AuthMiddleware(), RoleCheckMiddleware()],
    ),

    GetPage(
      name: _Paths.ADD_ADDRESS,
      page: () => const AddAddressView(),
      binding: AddAddressBinding(),
      middlewares: [AuthMiddleware(), RoleCheckMiddleware()],
    ),

    GetPage(
      name: _Paths.SERVICES_ADMIN,
      page: () => const ServicesListView(),
      binding: ServicesBinding(),
      middlewares: [AuthMiddleware(), RoleCheckMiddleware()],
    ),

    GetPage(
      name: _Paths.ORDERS_ADMIN,
      page: () => const ManageOrdersView(),
      binding: AdminOrderBinding(),
      middlewares: [AuthMiddleware(), RoleCheckMiddleware()],
    ),

    GetPage(
      name: _Paths.CUSTOMERS_ADMIN,
      page: () => const ManageCustomersView(),
      binding: CustomerBinding(),
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
