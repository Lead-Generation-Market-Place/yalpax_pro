import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/constants/app_colors.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/core/widgets/custom_button.dart';
import 'package:yalpax_pro/core/widgets/advanced_dropdown_field.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';

class FirstStep extends GetView<AuthController> {
  const FirstStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // AppBar as SliverAppBar
              SliverAppBar(
                backgroundColor: AppColors.surface,
                elevation: 0,
                pinned: true,
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

              // Main content area
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Category dropdown (single-select)
                    Obx(() => _buildCategoryDropdown()),
                    const SizedBox(height: 16),
                    // Subcategory dropdown (single-select)
                    Obx(() => _buildSubCategoryDropdown()),
                    const SizedBox(height: 16),
                    // Services dropdown (multi-select)
                    Obx(() => _buildServicesDropdown()),
                    // Add space for the fixed button
                    SizedBox(height: 80), // Same height as your button container
                  ]),
                ),
              ),
            ],
          ),

          // Fixed position button at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 50,
            child: _buildNextButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    final selectedCategory = controller.allCategories.firstWhere(
      (s) => controller.selectedCategories.contains(s['id']),
      orElse: () => {},
    );
    return AdvancedDropdownField<Map<String, dynamic>>(
      label: 'Select a category',
      hint: 'Search categories...',
      items: controller.filteredCategories,
      selectedValue: selectedCategory.isEmpty ? null : selectedCategory,
      getLabel: (item) => item['name'] ?? '',
      onChanged: (selectedCategory) {
        if (selectedCategory != null) {
          controller.toggleCategories(selectedCategory['id']);
          controller.selectedSubCategories.clear();
        } else {
          controller.selectedCategories.clear();
        }
      },
      isRequired: true,
      enableSearch: true,
      onSearchChanged: controller.fetchCategories,
    );
  }

  Widget _buildSubCategoryDropdown() {
    final selectedSubCategory = controller.allSubCategories.firstWhere(
      (s) => controller.selectedSubCategories.contains(s['id']),
      orElse: () => {},
    );
    return AdvancedDropdownField<Map<String, dynamic>>(
      label: 'Select a sub-category',
      hint: 'Search sub-categories...',
      items: controller.filteredSubCategories,
      selectedValue: selectedSubCategory.isEmpty ? null : selectedSubCategory,
      getLabel: (item) => item['name'] ?? '',
      onChanged: (selectedSubCategory) {
        if (selectedSubCategory != null) {
          controller.toggleSubCategories(selectedSubCategory['id']);
        } else {
          controller.selectedSubCategories.clear();
        }
      },
      isRequired: true,
      enableSearch: true,
      onSearchChanged: controller.fetchSubCategories,
    );
  }

  Widget _buildServicesDropdown() {
    final selectedServices = controller.allServices.where(
      (s) => controller.selectedServices.contains(s['id']),
    ).toList();
    return AdvancedDropdownField<Map<String, dynamic>>(
      label: 'Select services',
      hint: 'Search services...',
      items: controller.filteredServices,
      selectedValues: selectedServices,
      getLabel: (item) => item['name'] ?? '',
      onMultiChanged: (selectedServices) {
        controller.selectedServices.clear();
        for (var service in selectedServices) {
          if (service['id'] != null) {
            controller.selectedServices.add(service['id']);
          }
        }
      },
      isRequired: true,
      enableSearch: true,
      multiSelect: true,
      onSearchChanged: controller.fetchServices,
    );
  }

  Widget _buildNextButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.neutral200, width: 1)),
      ),
      child: CustomButton(
        height: 48,
        text: 'Next',
        onPressed: () {
          if (controller.selectedServices.isNotEmpty) {
            Get.toNamed(Routes.secondStep);
          } else {
            Get.snackbar(
              'Error',
              'Please select at least one service',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
      ),
    );
  }
}