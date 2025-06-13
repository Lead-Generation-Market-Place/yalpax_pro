import 'package:get/get.dart';
import 'package:yalpax_pro/feature/initial_page/controllers/initial_page_controller.dart';


class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InitialPageController>(() => InitialPageController());
  }
}