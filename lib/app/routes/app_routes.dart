// app_routes.dart
part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const HOME = _Paths.HOME;
  static const ORDER = _Paths.ORDER;
  static const MY_ORDERS = _Paths.MY_ORDERS;
  static const ORDERS_HISTORY = _Paths.ORDERS_HISTORY;
  static const ADMIN_DASHBOARD = _Paths.ADMIN_DASHBOARD;
  static const SERVICES_ADMIN = _Paths.SERVICES_ADMIN;
  static const SERVICE_FORM = _Paths.SERVICE_FORM;
  static const LOCATION = _Paths.LOCATION;
}

abstract class _Paths {
  _Paths._();
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const HOME = '/home';
  static const ORDER = '/order';
  static const MY_ORDERS = '/my-orders';
  static const ORDERS_HISTORY = '/orders-history';
  static const ADMIN_DASHBOARD = '/admin-dashboard';
  static const SERVICES_ADMIN = '/admin/services';
  static const SERVICE_FORM = '/admin/services/form';
  static const LOCATION = '/location';
}
