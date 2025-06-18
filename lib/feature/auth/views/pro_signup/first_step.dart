import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/constants/app_colors.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/core/widgets/custom_button.dart';
import 'package:yalpax_pro/core/widgets/foldable_widgets.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';
import 'package:yalpax_pro/core/widgets/advanced_dropdown_field.dart';

class FirstStep extends GetView<AuthController> {
  const FirstStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveContainer(
        child: Column(
          children: [
            // Header
            AppBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => Get.back(),
              ),
              title: Text(
                'Add Services you offer',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            ),

            // Using the custom dropdown with search connected to controller
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Obx(() {
                    final selectedCategory = controller.allCategories
                        .firstWhere(
                          (s) =>
                              controller.selectedCategories.contains(s['id']),
                          orElse: () => {},
                        );

                    return AdvancedDropdownField<Map<String, dynamic>>(
                      label: 'Select a category',
                      hint: 'Search categories...',
                      items: controller
                          .filteredCategories, // Use filteredCategories
                      selectedValue: selectedCategory.isEmpty
                          ? null
                          : selectedCategory,
                      getLabel: (item) => item['name'] ?? '',
                      onChanged: (selectedCategory) {
                        if (selectedCategory != null) {
                          controller.toggleCategories(selectedCategory['id']);
                          // Clear subcategories when category changes
                          controller.selectedSubCategories.clear();
                        } else {
                          controller.selectedCategories.clear();
                        }
                      },
                      isRequired: true,
                      enableSearch: true,
                      onSearchChanged:
                          controller.fetchCategories, // Use fetchCategories
                    );
                  }),

                  // Subcategory dropdown
                  Obx(() {
                    final selectedSubCategory = controller.allSubCategories
                        .firstWhere(
                          // Use allSubCategories
                          (s) => controller.selectedSubCategories.contains(
                            s['id'],
                          ),
                          orElse: () => {},
                        );

                    return AdvancedDropdownField<Map<String, dynamic>>(
                      label: 'Select a sub-category',
                      hint: 'Search sub-categories...',
                      items: controller
                          .filteredSubCategories, // Use filteredSubCategories
                      selectedValue: selectedSubCategory.isEmpty
                          ? null
                          : selectedSubCategory,
                      getLabel: (item) => item['name'] ?? '',
                      onChanged: (selectedSubCategory) {
                        if (selectedSubCategory != null) {
                          controller.toggleSubCategories(
                            selectedSubCategory['id'],
                          );
                        } else {
                          controller.selectedSubCategories.clear();
                        }
                      },
                      isRequired: true,
                      enableSearch: true,
                      onSearchChanged: controller
                          .fetchSubCategories, // Use fetchSubCategories
                    );
                  }),
                  const SizedBox(height: 16),
                 
              
                  // Services dropdown
             Obx(() {
  final selectedService = controller.allServices.firstWhere(
    (s) => controller.selectedServices.contains(s['id']),
    orElse: () => {},
  );

  return AdvancedDropdownField<Map<String, dynamic>>(
    label: 'Select a service',
    hint: 'Search services...',
    items: controller.filteredServices,  // Use filteredServices
    selectedValue: selectedService.isEmpty ? null : selectedService,
    getLabel: (item) => item['name'] ?? '',
    onChanged: (selectedService) {
      if (selectedService != null) {
        controller.toggleService(selectedService['id']);
      } else {
        controller.selectedServices.clear();
      }
    },
    isRequired: true,
    enableSearch: true,
    onSearchChanged: controller.fetchServices,  // Use fetchServices
  );
}),
                ],
              ),
            ),

            // Next button
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral200.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: CustomButton(
        text: 'Next',
        onPressed: () {
          if (controller.selectedServices.isNotEmpty) {
            Get.toNamed(Routes.secondStep);
          } else {
            Get.snackbar(
              'Error',
              'Please select a service',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
      ),
    );
  }
}
