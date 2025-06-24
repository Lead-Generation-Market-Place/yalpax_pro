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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.selectedServices.clear();
      controller.selectedCategories.clear();
      controller.selectedSubCategories.clear();
    });
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
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
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Obx(() => _buildCategoryDropdown()),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Obx(() => _buildSubCategoryDropdown()),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Obx(() => _buildServicesDropdown()),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80), // Space for button
                ),
              ],
            ),
            Align(
              // Use Align instead of Positioned for more reliable positioning
              alignment: Alignment.bottomCenter,
              child: _buildNextButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    final selectedCategory = controller.allCategories.firstWhere(
      (s) =>
          s['id'] != null &&
          controller.selectedCategories.contains(s['id'].toString()),
      orElse: () => {},
    );

    return AdvancedDropdownField<Map<String, dynamic>>(
      label: 'Select a category',
      hint: 'Search categories...',
      items: controller.filteredCategories,
      selectedValue: selectedCategory.isEmpty ? null : selectedCategory,
      getLabel: (item) => item['name'] ?? '',
      onChanged: (selectedCategory) {
        if (selectedCategory != null && selectedCategory['id'] != null) {
          controller.toggleCategories(selectedCategory['id'].toString());
          controller.selectedSubCategories.clear();
          controller.selectedServices.clear();
        } else {
          controller.selectedCategories.clear();
          controller.selectedSubCategories.clear();
          controller.allSubCategories.clear();
          controller.selectedServices.clear();
          controller.allServices.clear();
        }
      },
      validator: (value) {
        if (value == null || controller.selectedCategories.isEmpty) {
          return 'Please select a category';
        }
        return null;
      },
      isRequired: true,
      enableSearch: true,
      onSearchChanged: controller.fetchCategories,
    );
  }

  Widget _buildSubCategoryDropdown() {
    final selectedSubCategory = controller.categorySubCategories.firstWhere(
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
          controller.toggleSubCategories(selectedSubCategory['id'].toString());
        } else {
          controller.selectedSubCategories.clear();
          controller.selectedServices.clear();
          controller.allServices.clear();
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a sub-category';
        }
        return null;
      },
      isRequired: true,
      enableSearch: true,
      onSearchChanged: (query) {
        // Local search instead of database query
        if (query.isEmpty) {
          controller.filteredSubCategories.assignAll(
            controller.categorySubCategories,
          );
        } else {
          controller.filteredSubCategories.assignAll(
            controller.categorySubCategories
                .where(
                  (subCat) => (subCat['name'] as String).toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList(),
          );
        }
      },
    );
  }

  Widget _buildServicesDropdown() {
    // Get services for the selected subcategory
    final selectedServices = controller.subCategoryServices
        .where((s) => controller.selectedServices.contains(s['id']))
        .toList();

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
            controller.selectedServices.add(service['id'].toString());
          }
        }
      },
      validator: (values) {
        if (values == null || values.isEmpty) {
          return 'Please select at least one service';
        }
        return null;
      },
      isRequired: true,
      enableSearch: true,
      multiSelect: true,
      onSearchChanged: (query) {
        // Local search instead of database query
        if (query.isEmpty) {
          controller.filteredServices.assignAll(controller.subCategoryServices);
        } else {
          controller.filteredServices.assignAll(
            controller.subCategoryServices
                .where(
                  (service) => (service['name'] as String)
                      .toLowerCase()
                      .contains(query.toLowerCase()),
                )
                .toList(),
          );
        }
      },
    );
  }

  Widget _buildNextButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(() {
        final isValid =
            controller.selectedCategories.isNotEmpty &&
            controller.selectedSubCategories.isNotEmpty &&
            controller.selectedServices.isNotEmpty;

        return CustomButton(
          text: 'Next',
          onPressed: isValid ? () => Get.toNamed(Routes.secondStep) : null,
          enabled: isValid,
          isFullWidth: true,
        );
      }),
    );
  }
}
