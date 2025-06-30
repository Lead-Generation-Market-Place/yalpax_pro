import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:logger/web.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';
import 'package:yalpax_pro/feature/auth/services/auth_service.dart';

class jobsController extends GetxController {
  final AuthController authController = Get.put(AuthController());
  final AuthService authService = Get.put(AuthService());
  var isStep = false.obs;

  Future<void> checkAuthAndNavigate() async {
    try {
      final user = authController.supabase.auth.currentUser;

      if (user == null) {
        Get.offAllNamed(Routes.login);
        return;
      }

      final complete = await authController.isProfileComplete();
      if (complete) {
        Get.offAllNamed(Routes.jobs);
      } else {
        isStep.value = true; // Set isStep to true here
        Get.offAllNamed(Routes.firstStep);
      }
    } catch (e) {
      print(e);
    }
  }
}
