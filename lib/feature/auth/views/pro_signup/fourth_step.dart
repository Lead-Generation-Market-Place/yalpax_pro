import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/core/widgets/custom_button.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';

class FourthStep extends GetView<AuthController> {
  const FourthStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Header
                    const Text(
                      'Set Up Your Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Complete these steps to start getting clients',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Progress Steps
                    _buildProgressStep(
                      number: '1',
                      isActive: true,
                      title: 'Build a winning business profile',
                      description: 'Your profile is free, but it takes time to make it great. It\'s worth it - this is how you\'ll get hired.',
                    ),
                    const SizedBox(height: 24),
                    _buildProgressStep(
                      number: '2',
                      isActive: false,
                      title: 'Add your preferences',
                      description: 'Help us understand your work style and preferences.',
                    ),
                  ],
                ),
              ),

              // Bottom Button Section
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: CustomButton(
                  onPressed: () => Get.toNamed(Routes.fifthStep),
                  text: 'Continue',
                  height: 54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStep({
    required String number,
    required bool isActive,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Number Circle
        CircleAvatar(
          radius: 14,
          backgroundColor: isActive ? Colors.blue : const Color(0xFFEAECEE),
          child: Text(
            number,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? Colors.black87 : Colors.black54,
                ),
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
