import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/constants/app_colors.dart';
import 'package:yalpax_pro/core/constants/file_urls.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/core/widgets/custom_button.dart';
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

  bool hasUploadedGoogleImage = false;

  Future<void> initializeData() async {
    try {
      controller.profilePictureUrl.value;
      await controller.loadUserData();
      if (controller.googleAccountPictureUrl.value.isNotEmpty &&
          controller.profilePictureUrl.value.isEmpty &&
          !hasUploadedGoogleImage) {
        hasUploadedGoogleImage = true;
        await controller.uploadImageFromUrl(
          controller.googleAccountPictureUrl.value,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data: $e');
    } finally {
      controller.isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: BackButton(color: AppColors.textPrimary),
        elevation: 0,
        backgroundColor: Colors.transparent,
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
                                final localImage =
                                    controller.selectedImageFile.value;
                                final googleImage =
                                    controller.googleAccountPictureUrl.value;
                                final profileImage =
                                    '${FileUrls.profilePicture}${controller.profilePictureUrl.value}';

                                ImageProvider? imageProvider;
                                if (localImage != null) {
                                  imageProvider = FileImage(localImage);
                                } else if (googleImage.isNotEmpty) {
                                  imageProvider = NetworkImage(googleImage);
                                } else if (controller
                                    .profilePictureUrl
                                    .value
                                    .isNotEmpty) {
                                  imageProvider = NetworkImage(profileImage);
                                }

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
                                    image: imageProvider != null
                                        ? DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: imageProvider == null
                                      ? Center(
                                          child: Text(
                                            controller.name.value.isNotEmpty
                                                ? controller.name.value[0]
                                                      .toUpperCase()
                                                : '',
                                            style: TextStyle(
                                              fontSize: 60,
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
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
                                  onTap: () => controller
                                      .showImagePickerBottomSheet(context),
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
                        final hasLocalImage =
                            controller.selectedImageFile.value != null;
                        final hasGoogleImage =
                            controller.googleAccountPictureUrl.value.isNotEmpty;
                        final hasProfileImage =
                            controller.profilePictureUrl.value.isNotEmpty;

                        if (!hasLocalImage &&
                            !hasGoogleImage &&
                            !hasProfileImage) {
                          Get.snackbar(
                            'Profile Picture Required',
                            'Please upload or select a profile picture to continue.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
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
