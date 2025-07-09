import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/constants/app_colors.dart';
import 'package:yalpax_pro/core/widgets/bottom_navbar.dart';
import 'package:yalpax_pro/core/widgets/custom_app_bar.dart';
import 'package:yalpax_pro/core/widgets/custom_input.dart';
import 'package:yalpax_pro/feature/profile/controller/profile_controller.dart';

class BusinessInfo extends GetView<ProfileController> {
  const BusinessInfo({super.key});

  @override
  Widget build(BuildContext context) {
    // Future.microtask(() async {
    //   await controller
    //       .userBusinessProfile(); // ✅ Fetch profile data when screen loads
    // });
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Business Info',
        showSetupBanner: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15), // Add some right padding
            child: TextButton(
              onPressed: () {
                controller.saveBusinessInfo();
              },
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavbar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewPadding.bottom + 80,
            left: 16,
            right: 16,
          ),
          child: Column(
            // <-- Removed Expanded here
            children: [
              SizedBox(height: 40),
              const Text(
                'About your business',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              CustomInput(
                controller: controller.employeesController,
                label: 'Number of employees',
                hint: '5',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),

              // Contact Information Section
              const Text(
                'Contact information',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              CustomInput(
                controller: controller.phoneController,
                label: 'Phone number',
                hint: '(202) 590-4857',
                type: CustomInputType.phone,
              ),
              const SizedBox(height: 16),

              CustomInput(
                controller: controller.addressController,
                label: 'Address',
                hint: '5601 Seminary',
              ),
              const SizedBox(height: 16),

              CustomInput(
                controller: controller.suiteController,
                label: 'Suite/Apt',
                hint: '2026N',
              ),
              const SizedBox(height: 16),

              CustomInput(
                controller: controller.zipCodeController,
                label: 'Zip code',
                hint: '22041',
                type: CustomInputType.number,
              ),
              const SizedBox(height: 16),

              CustomInput(
                controller: controller.websiteController,
                label: 'Website',
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 32),

              // Payment Methods Section
              const Text(
                'Payment methods accepted',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              ...controller.availablePaymentMethods.map((method) {
                return CheckboxListTile(
                  title: Text(method),
                  value: controller.selectedPaymentMethods.contains(method),
                  onChanged: (bool? value) {
                    controller.togglePaymentMethod(method);
                  },
                );
              }).toList(),
              const SizedBox(height: 32),

              // Social Media Section
              const Text(
                'Social media',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              CustomInput(
                controller: controller.facebookController,
                label: 'Facebook',
                prefix: const Text('https://'),
              ),
              const SizedBox(height: 16),

              CustomInput(
                controller: controller.twitterController,
                label: 'Twitter',
              ),
              const SizedBox(height: 16),

              CustomInput(
                controller: controller.instagramController,
                label: 'Instagram',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
