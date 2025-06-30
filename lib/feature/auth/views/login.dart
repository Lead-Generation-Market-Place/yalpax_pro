import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/constants/app_colors.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/core/widgets/custom_button.dart';
import 'package:yalpax_pro/core/widgets/custom_input.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';
import 'package:yalpax_pro/feature/auth/services/auth_service.dart';

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
                  'SIGN IN TO YALPAX PRO',
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
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    } else if (!GetUtils.isEmail(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Password Field
                CustomInput(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: controller.passwordController,
                  type: CustomInputType.password,
                  prefixIcon: const Icon(Icons.lock_outline),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
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
                      'Forgot password?',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Sign In Button
                CustomButton(
                  text: 'SIGN IN',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      controller.login();
                    }
                  },
                  isFullWidth: true,
                ),
                const SizedBox(height: 24),
                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'OR',
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
                      'Don\'t have an account?',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: () {
                        Get.toNamed(Routes.firstStep);
                      },
                      child: Text(
                        'SIGN UP',
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
                    value: 'en_US',
                    icon: const Icon(Icons.arrow_drop_down),
                    underline: const SizedBox(),
                    items: [
                      DropdownMenuItem(
                        value: 'en_US',
                        child: Text(
                          'English (United States)',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (String? newValue) {},
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
                        'Privacy',
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
                        'Terms',
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
                      'Username not found in Google profile.',
                    );
                    return;
                  }
                  authService.isAuthenticated.value = true;
                  Get.offAllNamed(Routes.jobs);

                  // await controller.handlePostLogin(
                  //   user: res.user,
                  //   usernameFromOAuth: res.user?.userMetadata?['name'],
                  // );
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
              onPressed: () => controller.signInWithApple(),
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

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:yalpax_pro/core/constants/app_colors.dart';
// import 'package:yalpax_pro/core/routes/routes.dart';
// import 'package:yalpax_pro/core/widgets/custom_button.dart';
// import 'package:yalpax_pro/core/widgets/custom_input.dart';
// import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';

// class LoginView extends GetView<AuthController> {
//   LoginView({super.key});

//   // ✅ Global form key (to persist state)

//   final loginFormKey = GlobalKey<FormState>();
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isDesktop = screenWidth >= 800;

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: GestureDetector(
//         onTap: () => FocusScope.of(context).unfocus(), // ✅ dismiss keyboard
//         child: SingleChildScrollView(
//           padding: EdgeInsets.symmetric(
//             horizontal: 24,
//             vertical: isDesktop ? 50 : 100,
//           ),
//           child: Center(
//             child: Container(
//               constraints: BoxConstraints(
//                 maxWidth: isDesktop ? 500 : double.infinity,
//               ),
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 12,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   _buildLogo(),
//                   const SizedBox(height: 24),
//                   _buildWelcomeText(),
//                   const SizedBox(height: 16),
//                   _buildLoginForm(),
//                   const SizedBox(height: 16),
//                   _buildSocialLogin(),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLogo({bool isLight = false}) {
//     return Center(
//       child: Image.asset(
//         'assets/images/login.png',
//         height: 60,
//         color: isLight ? AppColors.textOnPrimary : AppColors.primaryBlue,
//       ),
//     );
//   }

//   Widget _buildWelcomeText() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Welcome Back',
//           style: TextStyle(
//             color: AppColors.textPrimary,
//             fontSize: 32,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           'Sign in to continue',
//           style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
//         ),
//       ],
//     );
//   }

//   Widget _buildLoginForm() {
//     return Obx(() {
//       return Form(
//         key: loginFormKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             CustomInput(
//               label: 'Email',
//               hint: 'Enter your email',
//               controller: controller.emailController,
//               keyboardType: TextInputType.emailAddress,
//               prefixIcon: const Icon(Icons.email_outlined),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Email is required';
//                 } else if (!GetUtils.isEmail(value)) {
//                   return 'Please enter a valid email';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 16),
//             CustomInput(
//               label: 'Password',
//               hint: 'Enter your password',
//               controller: controller.passwordController,
//               type: CustomInputType.password,
//               prefixIcon: const Icon(Icons.lock_outline),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Password is required';
//                 } else if (value.length < 6) {
//                   return 'Password must be at least 6 characters';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 8),
//             Align(
//               alignment: Alignment.centerRight,
//               child: TextButton(
//                 onPressed: () => Get.toNamed(Routes.resetPassword),
//                 child: Text(
//                   'Forgot Password?',
//                   style: TextStyle(
//                     color: AppColors.primaryBlue,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             CustomButton(
//               text: 'Sign In',
//               isLoading: controller.isLoading.value,
//               onPressed: () {
//                 final isValid = loginFormKey.currentState?.validate() ?? false;
//                 if (isValid) {
//                   controller.login();
//                 }
//               },
//               size: CustomButtonSize.large,
//               isFullWidth: true,
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   'Don\'t have an account? ',
//                   style: TextStyle(color: AppColors.textSecondary),
//                 ),
//                 TextButton(
//                   onPressed: () => Get.toNamed(Routes.signup_with_email),
//                   child: Text(
//                     'Register',
//                     style: TextStyle(
//                       color: AppColors.primaryBlue,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       );
//     });
//   }

//   Widget _buildSocialLogin() {
//     return Column(
//       children: [
//         // Row(
//         //   children: [
//         //     Expanded(child: Divider(color: AppColors.neutral200)),
//         //     Padding(
//         //       padding: const EdgeInsets.symmetric(horizontal: 16),
//         //       child: Text(
//         //         'Or continue with',
//         //         style: TextStyle(color: AppColors.textTertiary),
//         //       ),
//         //     ),
//         //     Expanded(child: Divider(color: AppColors.neutral200)),
//         //   ],
//         // ),
//         const SizedBox(height: 24),
//         Wrap(
//           alignment: WrapAlignment.center,
//           spacing: 16,
//           runSpacing: 16,
//           children: [
//             _buildSocialButton(
//               icon: 'assets/images/google.png',
//               onPressed: () async {
//                 final res = await AuthController.signInWithGoogle();
//                 final user = res.user;

//                 if (user != null && user.email != null) {
//                   final name = user.userMetadata?['name'];
//                   if (name == null || name.trim().isEmpty) {
//                     Get.snackbar(
//                       'Error',
//                       'Username not found in Google profile.',
//                     );
//                     return;
//                   }

//                   await controller.handlePostLogin(
//                     user: res.user,
//                     usernameFromOAuth: res.user?.userMetadata?['name'],
//                   );
//                 }
//               },
//             ),
//             // Uncomment if you have GitHub login
//             _buildSocialButton(
//               icon: 'assets/icon/y_logo.png', // Make sure this asset exists
//               onPressed: () => {Get.toNamed(Routes.initial)},
//             ),
//             // _buildSocialButton(
//             //   icon: 'assets/icons/apple.png',
//             //   onPressed: () => controller.signInWithApple(),
//             // ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildSocialButton({
//     required String icon,
//     required VoidCallback onPressed,
//   }) {
//     // Check if it's the Apple icon and use Material icon instead
//     if (icon == 'assets/icons/apple.png') {
//       return InkWell(
//         onTap: onPressed,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             border: Border.all(color: AppColors.neutral200),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(Icons.apple, size: 24, color: AppColors.textPrimary),
//         ),
//       );
//     }
//     return InkWell(
//       onTap: onPressed,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           border: Border.all(color: AppColors.neutral200),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Image.asset(icon, height: 24, width: 24),
//       ),
//     );
//   }
// }
