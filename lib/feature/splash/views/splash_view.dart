import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo or App Name
            Image.asset(
              'assets/icon/y_logo.png', // Replace with your actual logo path
              height: 120,
              width: 120,
            ),
            const SizedBox(height: 24),
            const Text(
              'Yalpax Pro',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Loading indicator - shows immediately since initialization starts automatically
            Obx(
              () => controller.isInitialized.value
                  ? const SizedBox.shrink() // Hide when initialized
                  : const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}