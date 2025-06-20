import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/core/widgets/custom_button.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';

class FifthStep extends GetView<AuthController> {
  const FifthStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create your free account.',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Avatar + Name
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundImage: AssetImage(
                        'assets/images/avatar_placeholder.png',
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Text(
                    //   controller.fullName.value, // e.g. "Feroz Durrani"
                    //   style: const TextStyle(
                    //     fontWeight: FontWeight.bold,
                    //     fontSize: 16,
                    // ),
                    // ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Email (non-editable)
              TextFormField(
                initialValue: controller.email.value,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Phone input
              TextField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '(937) 056-3174',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Checkbox
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

              // Terms + Privacy
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

              // Continue button
              CustomButton(
                text: 'Continue',
                onPressed: () {
                  Get.toNamed(Routes.sixthstep);
                  controller.registerUser();
                },
              ),
            ],
          );
        }),
      ),
    );
  }
}
