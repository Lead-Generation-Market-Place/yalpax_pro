import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../controllers/theme_controller.dart';
import '../../feature/splash/controllers/splash_controller.dart';
import '../../feature/auth/controllers/auth_controller.dart';
import '../../feature/jobs/controllers/jobs_controller.dart';

class ServiceBindings extends Bindings {
  @override
  Future<void> dependencies() async {
    try {
      // Core Controllers
 
      
      // Initialize JobsController first since it no longer depends on AuthController
      Get.put(JobsController(), permanent: true);
      
      // Then initialize AuthController which depends on JobsController
      Get.put(AuthController(), permanent: true);
      
      // Finally initialize SplashController which depends on auth
      Get.put(SplashController(), permanent: true);

      debugPrint('All core services initialized successfully');
    } catch (e) {
      debugPrint('Error initializing services: $e');
      rethrow;
    }
  }
}
