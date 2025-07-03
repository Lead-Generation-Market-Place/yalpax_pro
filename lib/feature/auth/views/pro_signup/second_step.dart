import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/constants/app_colors.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';

class SecondStep extends GetView<AuthController> {
  const SecondStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
       leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.black),
 onPressed: () => Get.offAllNamed(Routes.initial),

  ),
        actions: [
          TextButton(
            onPressed: () => Get.toNamed(Routes.login),
            child: const Text('Log in', style: TextStyle(color: Colors.blue)),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const Icon(Icons.location_on_outlined, size: 32),
                    const SizedBox(height: 16),
                    const Text(
                      "New customers are waiting.",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "There were 5,123 Cleaner jobs on Thumbtack last month in your area.",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Get.toNamed(Routes.signup_with_email),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Sign up with email",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text("OR"),
                        ),
                        Expanded(child: Divider(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSocialLogin(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Terms of Use",
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                    TextSpan(
                      text: " and ",
                      style: TextStyle(fontSize: 12),
                    ),
                    TextSpan(
                      text: "Privacy Policy",
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                    TextSpan(
                      text: ".",
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLogin() {
    return Builder(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final horizontalPadding = screenWidth * 0.20;
        final clampedPadding = horizontalPadding.clamp(24.0, 80.0);

        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: clampedPadding,
            right: clampedPadding,
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildSocialButton(
                icon: 'assets/images/google.png',
                onPressed: () async {
                  final res = await AuthController.signInWithGoogle();
                  final user = res.user;

                  if (user != null && user.email != null) {
                    final name = user.userMetadata?['name'];
                    if (name == null || name.trim().isEmpty) {
                      Get.snackbar(
                        'Error',
                        'Username not found in Google profile.',
                      );
                      return;
                    }
                    await controller.handlePostLogin(
                      user: res.user,
                      usernameFromOAuth: res.user?.userMetadata?['name'],
                    );
                  }
                },
              ),
              _buildSocialButton(
                icon: 'assets/icon/facebook.png',
                onPressed: () => Get.toNamed(Routes.initial),
              ),
              _buildSocialButton(
                icon: 'assets/icon/linkedin.png',
                onPressed: () => controller.signInWithApple(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSocialButton({
    required String icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 56,
        width: 56,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.neutral200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.asset(icon, fit: BoxFit.contain),
      ),
    );
  }
}
