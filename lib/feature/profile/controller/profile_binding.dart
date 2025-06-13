import 'package:get/get.dart';
import 'package:yalpax_pro/feature/profile/controller/profile_controller.dart';



class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}