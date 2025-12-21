import 'package:get/get.dart';
import '../controllers/report_controller.dart';
import '../../../data/providers/report_provider.dart';

class ReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportProvider>(() => ReportProvider());
    Get.lazyPut<ReportController>(() => ReportController());
  }
}
