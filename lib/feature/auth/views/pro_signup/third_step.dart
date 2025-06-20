import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/constants/file_urls.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/core/widgets/custom_button.dart';
import 'package:yalpax_pro/core/widgets/custom_input.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';

class ThirdStep extends GetView<AuthController> {
  const ThirdStep({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async => await controller.loadUserData(),
    );

    final imageUrl = controller.profilePictureUrl.value;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create your free account.',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            controller.showImagePickerBottomSheet(context),
                        child: Obx(() {
                          final hasImage =
                              controller.profilePictureUrl.value.isNotEmpty;
                          return CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey,
                            backgroundImage: hasImage
                                ? NetworkImage(
                                    '${FileUrls.profilePicture}${controller.profilePictureUrl.value}',
                                  )
                                : null,
                            child: !hasImage
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  )
                                : null,
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => Text(
                          controller.name.value,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Obx(() {
                  return CustomInput(
                    initialValue: controller.email.value,
                    enabled: false,
                    label: 'Email',
                    hint: 'Enter your email',
                    prefixIcon: Icon(Icons.email),
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
                  prefixIcon: const Icon(
                    Icons.phone_android_outlined,
                  ), // ✅ This is the fix
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
                    Checkbox(
                      value: controller.enableTextMessages.value,
                      onChanged: (val) =>
                          controller.enableTextMessages.value = val ?? false,
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

                CustomButton(
                  text: 'Continue',
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      controller.registerUser();
                      Get.toNamed(Routes.fourthStep);
                    }
                  },
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
