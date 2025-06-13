import 'package:get/get.dart';
import 'package:yalpax_pro/feature/home/controllers/home_controller.dart';


class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
