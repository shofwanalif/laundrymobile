import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/httpdemo/bindings/http_binding.dart';
import '../modules/httpdemo/views/http_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),

    GetPage(
      name: _Paths.HTTPDEMO,
      page: () => const ServicesPage(),
      binding: HttpBinding(),
    ),
  ];
}
