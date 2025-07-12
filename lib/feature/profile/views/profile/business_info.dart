import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/constants/app_colors.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/core/widgets/bottom_navbar.dart';
import 'package:yalpax_pro/core/widgets/custom_button.dart';
import 'package:yalpax_pro/core/widgets/custom_input.dart';
import 'package:yalpax_pro/feature/jobs/controllers/jobs_controller.dart';
import 'package:yalpax_pro/feature/profile/controller/profile_controller.dart';

class BusinessInfo extends GetView<ProfileController> {
  const BusinessInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKeyBusinessInfo = GlobalKey<FormState>();
    final jobsController = Get.find<JobsController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: BottomNavbar(),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Black label banner
            Obx(() {
              if (jobsController.isLoading.value) {
                return const SizedBox.shrink();
              }

              return jobsController.isCount.value < 3
                  ? Container(
                      width: double.infinity,
                      color: const Color.fromARGB(255, 52, 51, 51),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Complete Your Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          CustomButton(
                            text: 'Finish Setup',
                            onPressed: () async {
                              await Get.toNamed(Routes.finishSetup);
                              jobsController.checkStep();
                            },
                            type: CustomButtonType.secondary,
                            size: CustomButtonSize.small,
                            height: 36,
                            width: 120,
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink();
            }),

            // AppBar-like container with elevation
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Get.back(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Business Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Expanded(
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
                        controller: controller.yearFoundedController,
                        label: 'Year Founded',
                        hint: '2000',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 24),

                      CustomInput(
                        controller: controller.employeesController,
                        label: 'Number of employees',
                        hint: '5',
                        keyboardType: TextInputType.number,
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
                        validator: (value) =>
                            value!.isEmpty ? 'Zip code is required' : null,
                      ),
                      const SizedBox(height: 16),
                
                      CustomInput(
                        controller: controller.websiteController,
                        label: 'Website',
                        keyboardType: TextInputType.url,
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
                                await controller.saveBusinessInfo(); // Call the save method
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
          ],
        ),
      ),
    );
  }
}
