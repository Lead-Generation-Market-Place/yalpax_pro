import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';

class Sixthstep extends GetView<AuthController> {
  const Sixthstep({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Illustration
            Center(
              child: Image.asset(
                'assets/images/business_profile.png', // Replace with actual image asset
                height: 250,
              ),
            ),

            const SizedBox(height: 32),

            // Stepper / Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.blue,
                        child: Text(
                          '1',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Build a winning business profile.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.only(left: 36),
                    child: Text(
                      'Your profile is free, but it takes time to make it great. It’s worth it — this is how you’ll get hired.',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Color(0xFFEAECEE),
                        child: Text(
                          '2',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Add your preferences',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Next button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to next screen
                    Get.toNamed(Routes.seventhStep);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
