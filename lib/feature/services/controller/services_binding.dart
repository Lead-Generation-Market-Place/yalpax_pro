import 'package:get/get.dart';
import 'package:yalpax_pro/feature/services/controller/services_controller.dart';

class ServicesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServicesController>(() => ServicesController());
  }
}
