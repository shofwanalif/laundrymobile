// app_routes.dart
part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const HTTPDEMO = _Paths.HTTPDEMO;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const HTTPDEMO = '/httpdemo';
}
