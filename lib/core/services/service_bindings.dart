import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:yalpax_pro/feature/auth/services/auth_service.dart';
import '../controllers/theme_controller.dart';
import '../../feature/splash/controllers/splash_controller.dart';
import '../../feature/auth/controllers/auth_controller.dart';
import '../../feature/jobs/controllers/jobs_controller.dart';

class ServiceBindings extends Bindings {
  @override
  Future<void> dependencies() async {
    try {
      debugPrint('Initializing core services...');
      
      // First initialize AuthService since other services depend on it
      final authService = Get.put(AuthService(), permanent: true);

      
      // Initialize JobsController before AuthController
      final jobsController = Get.put(JobsController(), permanent: true);
      
      // Initialize AuthController with dependencies
      final authController = Get.put(AuthController(), permanent: true);
      
      // Finally initialize SplashController which depends on auth
      Get.put(SplashController(), permanent: true);

      debugPrint('All core services initialized successfully');
    } catch (e) {
      debugPrint('Error initializing services: $e');
      rethrow;
    }
  }
}
