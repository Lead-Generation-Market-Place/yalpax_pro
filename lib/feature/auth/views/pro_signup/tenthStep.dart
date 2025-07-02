import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/core/widgets/custom_button.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';

class TenthStep extends GetView<AuthController> {
  const TenthStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 40, right: 20, left: 20),
        child: Column(
          children: [
            const SizedBox(height: 200), // Placeholder for illustration
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    // Step 1 done
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 30,
                      color: Colors.grey.shade300,
                    ),
                    // Step 2 current
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: const Text(
                        '2',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Build a winning business profile.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Add your preferences',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Target the jobs you want by telling us your availability, ideal job types, and work area.',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(), // Push the button to the bottom
            SizedBox(
              width: double.infinity,
              child: Obx(() {
                return CustomButton(
                  isLoading: controller.isLoading.value,
                  text: 'Next',
                  onPressed: () => Get.toNamed(Routes.eleventhStep),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
