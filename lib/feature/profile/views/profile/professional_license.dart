import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/core/widgets/advanced_dropdown_field.dart';
import 'package:yalpax_pro/core/widgets/custom_button.dart';
import 'package:yalpax_pro/core/widgets/custom_input.dart';
import 'package:yalpax_pro/feature/jobs/controllers/jobs_controller.dart';
import 'package:yalpax_pro/feature/profile/controller/profile_controller.dart';

class ProfessionalLicense extends GetView<ProfileController> {
  const ProfessionalLicense({super.key});

  @override
  Widget build(BuildContext context) {
    final jobsController = Get.find<JobsController>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.fetchLicenses();
      await controller.fetchStates();
    });

    return Scaffold(
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

            // AppBar-like row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              width: double.infinity,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 0.5),
                ),
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
                        'Professional License',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () async {
                      Get.defaultDialog(
                        title: 'Confirm Save',
                        middleText:
                            'Are you sure you want to save your license information?',
                        textConfirm: 'Yes',
                        textCancel: 'No',
                        confirmTextColor: Colors.white,
                        onConfirm: () async {
                          Get.back(); // Close dialog
                          await controller.saveProfessionalLicense();
                        },
                        onCancel: () {
                          // No need to call Get.back(); it closes automatically
                        },
                      );
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Customers prefer to hire licensed professionals.\nThumbstack will check the license information you provide against the state\'s public licensing database.',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 25),
                      Obx(
                        () => AdvancedDropdownField<String>(
                          label: 'State',
                          hint: 'Select state',
                          items: controller.states,
                          selectedValue: controller.selectedState.value.isEmpty
                              ? null
                              : controller.selectedState.value,
                          onChanged: (value) =>
                              controller.selectedState.value = value ?? '',
                          isRequired: true,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Obx(
                        () => AdvancedDropdownField<String>(
                          label: 'Type',
                          hint: 'Select license type',
                          items: controller.licenseTypes,
                          selectedValue:
                              controller.selectedLicenseType.value.isEmpty
                              ? null
                              : controller.selectedLicenseType.value,
                          onChanged: (value) =>
                              controller.selectedLicenseType.value =
                                  value ?? '',
                          isRequired: true,
                        ),
                      ),
                      const SizedBox(height: 25),
                      CustomInput(
                        controller: controller.licenseNumberController,
                        label: 'License number',
                        hint: 'Enter your license number',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'License number is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
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
