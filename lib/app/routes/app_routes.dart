// app_routes.dart
part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const HOME = _Paths.HOME;
  static const ADMIN_DASHBOARD = _Paths.ADMIN_DASHBOARD;
  static const HTTPDEMO = _Paths.HTTPDEMO;
  static const DIODEMO = _Paths.DIODEMO;
}

abstract class _Paths {
  _Paths._();
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const HOME = '/home';
  static const ADMIN_DASHBOARD = '/admin-dashboard';
  static const HTTPDEMO = '/httpdemo';
  static const DIODEMO = '/diodemo';
}
