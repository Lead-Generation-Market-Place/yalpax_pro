import 'package:get/get.dart';
import 'package:yalpax_pro/feature/auth/services/auth_service.dart';
import 'package:yalpax_pro/feature/splash/controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
        Get.lazyPut<AuthService>(() => AuthService());
   Get.lazyPut<SplashController>(() => SplashController());
  }
}
