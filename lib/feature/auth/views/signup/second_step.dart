import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/constants/app_colors.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/core/widgets/custom_button.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';

class SecondStep extends GetView<AuthController> {
  const SecondStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton(
            onPressed: () => controller.selectAllServices(),
            child: Text('Select all', style: TextStyle(color: AppColors.info)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          final selectedService = controller.selectedService.value;
          final services = controller.allServices;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select all the services you offer.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'You’ll show up in search results and get jobs for all services you select.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Previously selected service (disabled)
              CheckboxListTile(
                value: true,
                onChanged: null,
                title: Text(selectedService['name'] ?? ''),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const Divider(),

              // Other service options
              Expanded(
                child: ListView(
                  children: services.where((service) {
                    return service['id'] != selectedService['id'];
                  }).map((service) {
                    final isChecked = controller.selectedServices.contains(service['id']);
                    return CheckboxListTile(
                      value: isChecked,
                      onChanged: (val) {
                        controller.toggleService(service['id']);
                      },
                      title: Text(service['name'] ?? ''),
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),
              CustomButton(
                text: 'Next',
                onPressed: () {
                  // Proceed with selected services
                  controller.submitSelectedServices();
   Get.toNamed(Routes.thirdStep);
                },
              ),
            ],
          );
        }),
      ),
    );
  }
}
