import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yalpax_pro/core/constants/app_colors.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/core/widgets/custom_button.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';
import 'package:yalpax_pro/main.dart';

class SecondStep extends GetView<AuthController> {
  const SecondStep({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        actions: [
          TextButton(
            onPressed: () {
              // Navigate to login screen
            },
            child: const Text('Log in', style: TextStyle(color: Colors.blue)),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Icon(Icons.location_on_outlined, size: 32),
            const SizedBox(height: 12),
            const Text(
              "New customers are waiting.",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "There were 5,123 Cleaner jobs on Thumbtack last month in your area.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.toNamed(Routes.signup_with_email);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  "Sign up with email",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text("OR"),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final res = await AuthController.signInWithGoogle();
                  final user = res.user;

                  if (user != null && user.email != null) {
                    final email = user.email;
                    final userMetadata = user.userMetadata;
                    String? username = userMetadata?['name'];

                    if (username == null) {
                      Get.snackbar(
                        'Error',
                        'Username not found in Google profile.',
                      );
                      return;
                    }

                    // Check if user already exists by email
                    final existingUser = await supabase
                        .from('users_profiles')
                        .select()
                        .eq('email', email ?? '')
                        .maybeSingle();

                    if (existingUser != null) {
                      // User with this email already exists, redirect
                      Get.toNamed(Routes.thirdStep);
                      return;
                    }

                    // Check if username already exists
                    final usernameExists = await supabase
                        .from('users_profiles')
                        .select()
                        .eq('username', username)
                        .maybeSingle();

                    // Generate a unique username if needed
                    if (usernameExists != null) {
                      final random =
                          (1000 +
                                  (10000 - 1000) *
                                      (await Future.value(
                                        DateTime.now().millisecondsSinceEpoch %
                                            1000,
                                      )) /
                                      1000)
                              .toInt();
                      username = '${username}_$random';
                    }

                    // Insert new user
                    await supabase.from('users_profiles').insert({
                      'email': email,
                      'username': username,
                    });

                    Get.toNamed(Routes.thirdStep);
                  }
                },
                icon: const Icon(Icons.g_mobiledata),
                label: const Text("Sign up with Google"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Facebook signup
                },
                icon: const Icon(Icons.facebook, color: Colors.blue),
                label: const Text("Sign up with Facebook"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text:
                          "By tapping any of the Sign up buttons, you agree to the ",
                    ),
                    TextSpan(
                      text: "Terms of Use",
                      style: TextStyle(color: Colors.blue),
                    ),
                    TextSpan(text: " and "),
                    TextSpan(
                      text: "Privacy Policy",
                      style: TextStyle(color: Colors.blue),
                    ),
                    TextSpan(text: "."),
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
}
