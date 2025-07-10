import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/constants/app_colors.dart';
import 'package:yalpax_pro/core/widgets/bottom_navbar.dart';
import 'package:yalpax_pro/core/widgets/custom_app_bar.dart';
import 'package:yalpax_pro/core/widgets/custom_button.dart';
import 'package:yalpax_pro/core/widgets/custom_input.dart';
import 'package:yalpax_pro/feature/profile/controller/profile_controller.dart';

class BusinessInfo extends GetView<ProfileController> {
  const BusinessInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKeyBusinessInfo = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Business Info',
        showSetupBanner: true,
        showBackButton: true,

        onBack: () {
          Get.close(0);
        },
      ),
      bottomNavigationBar: BottomNavbar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewPadding.bottom + 80,
            left: 16,
            right: 16,
          ),
          child: Form(
            key: _formKeyBusinessInfo,
            child: Column(
              children: [
                const SizedBox(height: 40),
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
                  // validator: (value) =>
                  //     value!.isEmpty ? 'Number of employees is required' : null,
                ),
                const SizedBox(height: 32),

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
                  // validator: (value) =>
                  //     value!.isEmpty ? 'Phone number is required' : null,
                ),
                const SizedBox(height: 16),

                CustomInput(
                  controller: controller.addressController,
                  label: 'Address',
                  hint: '5601 Seminary',
                  // validator: (value) =>
                  //     value!.isEmpty ? 'Address is required' : null,
                ),
                const SizedBox(height: 16),

                CustomInput(
                  controller: controller.suiteController,
                  label: 'Suite/Apt',
                  hint: '2026N',
                  // validator: (value) =>
                  //     value!.isEmpty ? 'Suite/Apt is required' : null,
                ),
                const SizedBox(height: 16),

                CustomInput(
                  controller: controller.zipCodeController,
                  label: 'Zip code',
                  hint: '22041',
                  type: CustomInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Zip code is required' : null,
                ),
                const SizedBox(height: 16),
          
                CustomInput(
                  controller: controller.websiteController,
                  label: 'Website',
                  keyboardType: TextInputType.url,
                  // validator: (value) =>
                  //     value!.isEmpty ? 'Website is required' : null,
                ),
                const SizedBox(height: 32),

                const Text(
                  'Payment methods accepted',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                Obx(() {
                  return Column(
                    children: controller.availablePaymentMethods.map((method) {
                      return CheckboxListTile(
                        title: Text(method),
                        value: controller.selectedPaymentMethods.contains(
                          method,
                        ),
                        onChanged: (bool? value) {
                          controller.togglePaymentMethod(method);
                        },
                      );
                    }).toList(),
                  );
                }),
                const SizedBox(height: 32),

                const Text(
                  'Social media',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                CustomInput(
                  controller: controller.facebookController,
                  label: 'Facebook',
                  prefix: const Text('https://'),
                  // validator: (value) =>
                  //     value!.isEmpty ? 'Facebook is required' : null,
                ),
                const SizedBox(height: 16),

                CustomInput(
                  controller: controller.twitterController,
                  label: 'Twitter',
                  // validator: (value) =>
                  //     value!.isEmpty ? 'Twitter is required' : null,
                ),
                const SizedBox(height: 16),

                CustomInput(
                  controller: controller.instagramController,
                  label: 'Instagram',
                  // validator: (value) =>
                  //     value!.isEmpty ? 'Instagram is required' : null,
                ),

                const SizedBox(height: 20),

                CustomButton(
                  text: 'Save',
                  onPressed: () {
                    if (_formKeyBusinessInfo.currentState!.validate()) {
                      Get.defaultDialog(
                        title: 'Confirm Save',
                        middleText:
                            'Are you sure you want to save your business information?',
                        textConfirm: 'Yes',
                        textCancel: 'No',
                        confirmTextColor: Colors.white,
                        onConfirm: () async {
                          Get.back(); // Close dialog
                          await controller
                              .saveBusinessInfo(); // Call the save method
                        },
                        onCancel: () {
                          // No need to call Get.back(); it closes automatically
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
