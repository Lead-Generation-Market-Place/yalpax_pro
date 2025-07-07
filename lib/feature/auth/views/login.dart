import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yalpax_pro/core/constants/app_colors.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/core/widgets/custom_button.dart';
import 'package:yalpax_pro/core/widgets/custom_input.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';
import 'package:yalpax_pro/feature/auth/services/auth_service.dart';
import 'package:yalpax_pro/core/localization/localization.dart';

class LoginView extends GetView<AuthController> {
  LoginView({super.key});

  final AuthService authService = Get.find<AuthService>();

  final _formKey = GlobalKey<FormState>();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Logo/Header
                Image.asset(
                  'assets/icon/y_logo.png',
                  height: 80,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),
                // Title
                Text(
                  'SIGN IN TO YALPAX PRO'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Email Field
                CustomInput(
                  label: 'email'.tr,
                  hint: 'Enter your email'.tr,
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required'.tr;
                    } else if (!GetUtils.isEmail(value)) {
                      return 'Please enter a valid email'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Password Field
                CustomInput(
                  label: 'password'.tr,
                  hint: 'Enter your password'.tr,
                  controller: controller.passwordController,
                  type: CustomInputType.password,
                  prefixIcon: const Icon(Icons.lock_outline),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required'.tr;
                    } else if (value.length < 8) {
                      return 'Password must be at least 8 characters'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Get.toNamed(Routes.resetPassword);
                    },
                    child: Text(
                      'forgot_password'.tr,
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Sign In Button
                Obx(
                  () => CustomButton(
                    text: 'SIGN IN'.tr,
                    isLoading: controller.isLoading.value,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await controller.login();
                      }
                    },
                    isFullWidth: true,
                  ),
                ),
                const SizedBox(height: 24),
                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'OR'.tr,
                        style: TextStyle(
                          color: AppColors.neutral400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                // Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account?'.tr,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: () {
                        Get.toNamed(Routes.secondStep);
                      },
                      child: Text(
                        'SIGN UP'.tr,
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Language Selector
                _buildSocialLogin(),
                const SizedBox(height: 10),
                Center(
                  child: DropdownButton<String>(
                    value: LocalizationService.getCurrentLanguage(),
                    icon: const Icon(Icons.arrow_drop_down),
                    underline: const SizedBox(),
                    items: LocalizationService.languages
                        .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          );
                        })
                        .toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        LocalizationService.changeLocale(newValue);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Footer Links
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Open privacy policy
                      },
                      child: Text(
                        'Privacy'.tr,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () {
                        // Open terms
                      },
                      child: Text(
                        'Terms'.tr,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        // Row(
        //   children: [
        //     Expanded(child: Divider(color: AppColors.neutral200)),
        //     Padding(
        //       padding: const EdgeInsets.symmetric(horizontal: 16),
        //       child: Text(
        //         'Or continue with',
        //         style: TextStyle(color: AppColors.textTertiary),
        //       ),
        //     ),
        //     Expanded(child: Divider(color: AppColors.neutral200)),
        //   ],
        // ),
        const SizedBox(height: 24),
        Wrap(
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
                      'Username not found in Google profile.'.tr,
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
            // Uncomment if you have GitHub login
            _buildSocialButton(
              icon: 'assets/icon/facebook.png', // Make sure this asset exists
              onPressed: () => {Get.toNamed(Routes.initial)},
            ),
            _buildSocialButton(
              icon: 'assets/icon/linkedin.png',
              onPressed: () async {
                try {
                  // Start loading state
                  controller.isLoading.value = true;
                    
                  final response = await Supabase.instance.client.auth
                      .signInWithOAuth(
                        OAuthProvider.linkedinOidc,
                        redirectTo: 'yalpaxpro://login-callback',
                        // Use inAppWebView to better handle the flow
                        authScreenLaunchMode: LaunchMode.inAppBrowserView,
                        // Add scopes to get user profile data
                        scopes: 'openid profile email',
                      );

   

                  if (response) {
                    controller.isLinkedIn.value = true;
                    // Wait for auth state to update
                    await Future.delayed(const Duration(seconds: 2));
                    
                    // Get current user after OAuth
                    final user = Supabase.instance.client.auth.currentUser;
                    if (user != null) {
                      final linkedInIdentity = user.identities?.firstWhereOrNull(
                        (identity) => identity.provider == 'linkedin',
                      );
                      
                      final name = user.userMetadata?['name'] ??
                                 user.userMetadata?['full_name'] ??
                                 linkedInIdentity?.identityData?['name'] ??
                                 linkedInIdentity?.identityData?['full_name'];

                      if (name == null || name.toString().trim().isEmpty) {
                        Get.snackbar(
                          'Error',
                          'Username not found in LinkedIn profile.',
                          duration: const Duration(seconds: 3),
                        );
                        return;
                      }

                    //   await controller.handlePostLogin(
                    //     user: user,
                    //     usernameFromOAuth: name.toString(),
                    //   );
                    }
                  }

                  if (!response) {
                    Get.snackbar(
                      'Error',
                      'LinkedIn login failed. Please try again.',
                      duration: const Duration(seconds: 3),
                    );
                  }
                } catch (e) {
                  print('LinkedIn login error: $e');
                  Get.snackbar(
                    'Error',
                    'Failed to login with LinkedIn. Please try again.',
                    duration: const Duration(seconds: 3),
                  );
                } finally {
                  controller.isLoading.value = false;
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String icon,
    required VoidCallback onPressed,
  }) {
    // Check if it's the Apple icon and use Material icon instead
    if (icon == 'assets/icons/apple.png') {
      return InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.neutral200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.apple, size: 24, color: AppColors.textPrimary),
        ),
      );
    }
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.neutral200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.asset(icon, height: 24, width: 24),
      ),
    );
  }
}
