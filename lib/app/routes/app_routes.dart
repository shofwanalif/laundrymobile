// app_routes.dart
part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const HTTPDEMO = _Paths.HTTPDEMO;
  static const DIODEMO = _Paths.DIODEMO;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const HTTPDEMO = '/httpdemo';
  static const DIODEMO = '/diodemo';
}
