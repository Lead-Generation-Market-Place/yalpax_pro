import 'package:get/get.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';


class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}