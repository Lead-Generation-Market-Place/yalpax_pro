import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/constants/app_colors.dart';
import 'package:yalpax_pro/core/constants/file_urls.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/core/widgets/custom_button.dart';
import 'package:yalpax_pro/core/widgets/custom_flutter_toast.dart';
import 'package:yalpax_pro/core/widgets/custom_input.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';

class ThirdStep extends StatefulWidget {
  const ThirdStep({super.key});

  @override
  State<ThirdStep> createState() => _ThirdStepState();
}

class _ThirdStepState extends State<ThirdStep> {
  final AuthController controller = Get.put(AuthController());
  final formKeyThirdStep = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    try {
      await controller.loadUserData();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data: $e');
    } finally {
      controller.isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // leading: BackButton(color: AppColors.textPrimary),
  
        backgroundColor: Colors.white,
        title: Text(
          'Profile Setup',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: formKeyThirdStep,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Complete Your Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your details to create your professional profile',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Profile Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Profile Image Section
                        Center(
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Obx(() {
                                final localImage = controller.selectedImageFile.value;
                                
                                return Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[100],
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                    image: localImage != null
                                        ? DecorationImage(
                                            image: FileImage(localImage),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: localImage == null
                                      ? Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_a_photo_outlined,
                                              size: 48,
                                              color: AppColors.textSecondary,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Upload Photo',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: AppColors.textSecondary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            
                                          ],
                                        )
                                      : null,
                                );
                              }),
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(
                                  right: 8,
                                  bottom: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: GestureDetector(
                                  onTap: () => controller.showImagePickerBottomSheet(context),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Obx(
                          () => Text(
                            controller.name.value,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Contact Information Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Obx(() {
                          return CustomInput(
                            initialValue: controller.email.value,
                            enabled: false,
                            label: 'Email Address',
                            hint: 'Enter your email',
                            prefixIcon: Icon(
                              Icons.email,
                              color: AppColors.primaryBlue,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email is required';
                              }
                              return null;
                            },
                          );
                        }),
                        const SizedBox(height: 16),
                        CustomInput(
                          label: 'Phone Number',
                          keyboardType: TextInputType.phone,
                          autofocus: true,
                          prefixIcon: Icon(
                            Icons.phone_android,
                            color: AppColors.primaryBlue,
                          ),
                          hint: '(+1) 555-555-555',
                          controller: controller.phoneController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Phone number is required.';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Notifications Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Obx(
                              () => Switch(
                                value: controller.enableTextMessages.value,
                                onChanged: (val) =>
                                    controller.enableTextMessages.value = val,
                                activeColor: AppColors.primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Enable SMS Notifications',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Receive updates and notifications via text message',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Terms Section
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text.rich(
                      TextSpan(
                        text: 'By continuing, you agree to our ',
                        style: TextStyle(color: AppColors.textSecondary),
                        children: [
                          TextSpan(
                            text: 'Terms of Use',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Continue Button
                  Obx(
                    () => CustomButton(
                      text: 'Continue',
                      isLoading: controller.isLoading.value,
                      onPressed: () {
                        if (controller.selectedImageFile.value == null) {
                          CustomFlutterToast.showErrorToast(
                            'Please upload your business profile picture by clicking the camera icon.',
                          );
                          return;
                        }

                        if (formKeyThirdStep.currentState!.validate()) {
                          Get.toNamed(Routes.fourthStep);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
