import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  Future<void> initializeData() async {
    try {
      controller.profilePictureUrl.value;
      await controller.loadUserData();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data: $e');
    } finally {
      controller.isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = controller.profilePictureUrl.value;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: formKeyThirdStep,
          child: ListView(
            children: [
              const Text(
                'Create your free account.',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(() {
                        final localImage = controller.selectedImageFile.value;
                        final googleImage = controller.googleAccountPictureUrl.value;
                        final profileImage = '${FileUrls.profilePicture}${controller.profilePictureUrl.value}';

                        ImageProvider? imageProvider;
                        if (localImage != null) {
                          imageProvider = FileImage(localImage);
                        } else if (googleImage.isNotEmpty) {
                          imageProvider = NetworkImage(googleImage);
                        } else if (controller.profilePictureUrl.value.isNotEmpty) {
                          imageProvider = NetworkImage(profileImage);
                        }

                        return CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: imageProvider,
                          child: imageProvider == null
                              ? Text(
                                  controller.name.value.isNotEmpty
                                      ? controller.name.value[0].toUpperCase()
                                      : '',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : null,
                        );
                      }),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => controller.showImagePickerBottomSheet(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blueGrey,
                          textStyle: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        child: const Text('Change photo'),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => Text(
                          controller.name.value,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      // Optionally, add business/company name or role here
                      // Text(
                      //   'Business Owner',
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //     color: Colors.grey[600],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Obx(() {
                return CustomInput(
                  initialValue: controller.email.value,
                  enabled: false,
                  label: 'Email',
                  hint: 'Enter your email',
                  prefixIcon: const Icon(Icons.email),
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
                prefixIcon: const Icon(Icons.phone_android_outlined),
                hint: '  (+1) 555-555-555',
                controller: controller.phoneController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone number is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Obx(
                    () => Checkbox(
                      value: controller.enableTextMessages.value,
                      onChanged: (val) =>
                          controller.enableTextMessages.value = val ?? false,
                    ),
                  ),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'Enable text messages\n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text:
                                'By leaving this box checked and tapping Continue, you authorize us to send you automated text messages. ',
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                          TextSpan(
                            text: 'Terms apply.',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text.rich(
                TextSpan(
                  text: 'By tapping Continue, I agree to the ',
                  children: [
                    TextSpan(
                      text: 'Terms of Use',
                      style: TextStyle(color: Colors.blue),
                    ),
                    TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Obx(
                () => CustomButton(
                  text: 'Continue',
                  isLoading: controller.isLoading.value,
                  onPressed: () {
                    if (formKeyThirdStep.currentState!.validate()) {
                      Get.toNamed(Routes.fourthStep);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
