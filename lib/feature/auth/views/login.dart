import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/constants/app_colors.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/core/widgets/custom_button.dart';
import 'package:yalpax_pro/core/widgets/custom_input.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.emailController.clear();
      controller.passwordController.clear();
    });

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: isDesktop ? _buildDesktop(context) : _buildMobile(context),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogo(isLight: true),
                  const SizedBox(height: 24),
                  Text(
                    'Connect with US',
                    style: TextStyle(
                      color: AppColors.textOnPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildWelcomeText(),
                const SizedBox(height: 32),
                _buildLoginForm(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobile(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLogo(),
          const SizedBox(height: 32),
          _buildWelcomeText(),
          const SizedBox(height: 24),
          _buildLoginForm(),
        ],
      ),
    );
  }

  Widget _buildLogo({bool isLight = false}) {
    return Image.asset(
      'assets/images/login.png',
      height: 60,
      color: isLight ? AppColors.textOnPrimary : AppColors.primaryBlue,
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomInput(
            label: 'Email',
            hint: 'Enter your email',
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
            errorText: controller.emailError.value,
            onChanged: (value) {
              if (value.isEmpty) {
                controller.emailError.value = 'Email is required';
              } else if (!GetUtils.isEmail(value)) {
                controller.emailError.value = 'Please enter a valid email';
              } else {
                controller.emailError.value = null;
              }
            },
          ),
          const SizedBox(height: 16),
          CustomInput(
            label: 'Password',
            hint: 'Enter your password',
            controller: controller.passwordController,
            type: CustomInputType.password,
            prefixIcon: const Icon(Icons.lock_outline),
            errorText: controller.passwordError.value,
            onChanged: (value) {
              if (value.isEmpty) {
                controller.passwordError.value = 'Password is required';
              } else if (value.length < 6) {
                controller.passwordError.value =
                    'Password must be at least 6 characters';
              } else {
                controller.passwordError.value = null;
              }
            },
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Get.toNamed(Routes.resetPassword),
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Sign In',
            isLoading: controller.isLoading.value,
            onPressed: () {
              controller.emailError.value = null;
              controller.passwordError.value = null;

              final email = controller.emailController.text;
              final password = controller.passwordController.text;

              bool isValid = true;

              if (email.isEmpty) {
                controller.emailError.value = 'Email is required';
                isValid = false;
              } else if (!GetUtils.isEmail(email)) {
                controller.emailError.value = 'Please enter a valid email';
                isValid = false;
              }

              if (password.isEmpty) {
                controller.passwordError.value = 'Password is required';
                isValid = false;
              } else if (password.length < 6) {
                controller.passwordError.value =
                    'Password must be at least 6 characters';
                isValid = false;
              }

              if (isValid) {
                controller.login();
            
              }
            },
            size: CustomButtonSize.large,
            isFullWidth: true,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Don\'t have an account? ',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              TextButton(
                onPressed: () => Get.toNamed(Routes.signup_with_email),
                child: Text(
                  'Register',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}