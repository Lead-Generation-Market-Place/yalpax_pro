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

            // Search input
            _buildSearchSection(),
            _buildSearchSection(),

            // Services list
            _buildServicesList(),

            // Next button
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral200.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        if (controller.selectedServices.isNotEmpty) {
          final service = controller.allServices.firstWhere(
            (s) => controller.selectedServices.contains(s['id']),
            orElse: () => {},
          );
          if (service.isNotEmpty) {
            return _buildSelectedServiceDisplay(service);
          }
        }
        return _buildSearchField();
      }),
    );
  }

  Widget _buildSelectedServiceDisplay(Map<String, dynamic> service) {
    return Container(
      height: 35,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Icon(
              Icons.check_circle,
              color: AppColors.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              service['name'] ?? '',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: AppColors.neutral500,
              size: 20,
            ),
            onPressed: () {
              controller.selectedServices.clear();
              controller.searchController.clear();
              controller.fetchServices('');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 35,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller.searchController,
        decoration: InputDecoration(
          hintText: 'Search services...',
          hintStyle: TextStyle(color: AppColors.neutral500),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: AppColors.neutral500),
          suffixIcon: Obx(
            () => controller.showClearButton.value
                ? IconButton(
                    icon: Icon(Icons.clear, color: AppColors.neutral500),
                    onPressed: controller.clearSearch,
                  )
                : const SizedBox.shrink(),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        ),
      ),
    );
  }

  Widget _buildServicesList() {
    return Expanded(
      child: Obx(() {
        if (controller.selectedServices.isEmpty) {
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  controller.searchController.text.isEmpty
                      ? 'Available Services'
                      : 'Search Results',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (controller.isLoading.value)
                Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBlue,
                  ),
                )
              else if (controller.filteredServices.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No services found',
                    style: TextStyle(
                      color: AppColors.neutral500,
                      fontSize: 16,
                    ),
                  ),
                )
              else
                ...controller.filteredServices
                    .map(
                      (service) => ListTile(
                        onTap: () {
                          controller.toggleService(service['id']);
                          if (controller.selectedServices.isNotEmpty) {
                            controller.searchController.text =
                                service['name'] ?? '';
                          }
                        },
                        title: Text(
                          service['name'] ?? '',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.neutral500,
                          size: 16,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                      ),
                    )
                    .toList(),
            ],
          );
        }
        return const SizedBox.shrink();
      }),
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