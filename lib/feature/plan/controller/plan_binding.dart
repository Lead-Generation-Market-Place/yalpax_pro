import 'package:get/get.dart';
import 'package:yalpax_pro/feature/plan/controller/plan_controller.dart';


class PlanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlanController>(() => PlanController());
  }
}