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
      // Core Controllers - Initialize immediately
      Get.put(ThemeController(), permanent: true);
      Get.put(SplashController(), permanent: true);
      
      // Feature Controllers - Initialize immediately for critical features
      Get.put(AuthController(), permanent: true);
      Get.put(JobsController(), permanent: true);

      // Less critical controllers can be lazy loaded
      // Add your lazy loaded controllers here with fenix: true
      
      debugPrint('All core services initialized successfully');
    } catch (e) {
      debugPrint('Error initializing services: $e');
      rethrow;
    }
  }
}
