import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/constants/app_colors.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/core/widgets/custom_button.dart';
import 'package:yalpax_pro/core/widgets/foldable_widgets.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';


class FirstStep extends GetView<AuthController> {
  const FirstStep({super.key});

   @override
  Widget build(BuildContext context) {


    return Scaffold(
    
      body: ResponsiveContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40, // Adjust height as needed
                decoration: BoxDecoration(
                  color: AppColors.neutral50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: controller.searchController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Looking for a weekly house cleaner',
                    hintStyle: TextStyle(color: AppColors.neutral500),
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search, color: AppColors.neutral500),
                    suffixIcon: Obx(
                      () => controller.showClearButton.value
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: AppColors.neutral500),
                              onPressed: () {
                                controller.clearSearch();
                              },
                            )
                          : const SizedBox.shrink(), // Use SizedBox.shrink() instead of null
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Re-added horizontal padding for internal text field content
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.neutral50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: controller.zipCodeController,
                  decoration: InputDecoration(
                    hintText: 'Zip Code',
                    hintStyle: TextStyle(color: AppColors.neutral500),
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.location_on, color: AppColors.neutral500),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Re-added horizontal padding for internal text field content
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Obx(
                  () => controller.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : controller.searchController.text.isEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0), // Retained padding for text
                                  child: Text(
                                    'Popular services',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.neutral700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: controller.allServices.length,
                                    itemBuilder: (context, index) {
                                      final service = controller.allServices[index];
                                      return Column(
                                        children: [
                                          ListTile(
                                            title: Text(service['name'] ?? ''),
                                            visualDensity: VisualDensity.compact, // Make list tile a bit smaller
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), // Retained horizontal padding here
                                            onTap: () async {
                                              if (service['id'] != null) {
                                                await controller.fetchQuestions(service['id']);
                                                print('Tapped: ${service['name']}');
                                              }
                                            },
                                          ),
                                          Divider(height: 1, color: AppColors.neutral200), // Add a divider
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              itemCount: controller.filteredServices.length,
                              itemBuilder: (context, index) {
                                final service = controller.filteredServices[index];
                                return Column(
                                  children: [
                                    ListTile(
                                      title: Text(service['name'] ?? ''),
                                      visualDensity: VisualDensity.compact,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), // Retained horizontal padding here
                                      onTap: () async {
                                        if (service['id'] != null) {
                                          await controller.fetchQuestions(service['id']);
                                          print('Tapped: ${service['name']}');
                                        }
                                      },
                                    ),
                                    Divider(height: 1, color: AppColors.neutral200),
                                  ],
                                );
                              },
                            ),
                ),
              ),
              const SizedBox(height: 20,),
              CustomButton(text: 'Next',onPressed: () => Get.toNamed(Routes.secondStep),)
            ],
          ),
        ),
      ),
    );
  }
}
