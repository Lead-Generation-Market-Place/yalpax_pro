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
      appBar: AppBar(
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
      body: ResponsiveContainer(
        child: Column(
          children: [
            Obx(() {
              // Show search only when no services are selected
              if (controller.selectedServices.isEmpty) {
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
                  child: Column(
                    children: [
                      Container(
                        height: 35,
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
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 35,
                        decoration: BoxDecoration(
                          color: AppColors.neutral50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: controller.zipCodeController,
                          decoration: InputDecoration(
                            hintText: 'Enter your zip code',
                            hintStyle: TextStyle(color: AppColors.neutral500),
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.location_on, color: AppColors.neutral500),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            Expanded(
              child: Obx(
                () => ListView(
                  children: [
                    if (controller.selectedServices.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'Selected Services',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.neutral200,
                              width: 1,
                            ),
                          ),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.allServices
                              .where((service) => controller.selectedServices.contains(service['id']))
                              .length,
                          itemBuilder: (context, index) {
                            final service = controller.allServices
                                .where((service) => controller.selectedServices.contains(service['id']))
                                .toList()[index];
                            return Obx(() {
                              final isSelected = controller.selectedServices.contains(service['id']);
                              return Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withOpacity(0.05),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppColors.neutral200,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: CheckboxListTile(
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    controller.toggleService(service['id']);
                                  },
                                  title: Text(
                                    service['name'] ?? '',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  activeColor: AppColors.primaryBlue,
                                  checkColor: AppColors.textOnPrimary,
                                  controlAffinity: ListTileControlAffinity.leading,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                ),
                              );
                            });
                          },
                        ),
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        controller.selectedServices.isEmpty
                            ? (controller.searchController.text.isEmpty ? 'Related Services' : 'Search Results')
                            : 'Related Services',
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
                    else
                      ...(controller.selectedServices.isEmpty
                          ? (controller.searchController.text.isEmpty
                              ? controller.allServices
                              : controller.filteredServices)
                          : controller.filteredServices)
                          .where((service) => !controller.selectedServices.contains(service['id']))
                          .map((service) => Obx(() {
                                final isSelected = controller.selectedServices.contains(service['id']);
                                return Container(
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primaryBlue.withOpacity(0.05) : null,
                                    border: Border(
                                      bottom: BorderSide(
                                        color: AppColors.neutral200,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: CheckboxListTile(
                                    value: isSelected,
                                    onChanged: (bool? value) {
                                      controller.toggleService(service['id']);
                                    },
                                    title: Text(
                                      service['name'] ?? '',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                        fontSize: 16,
                                      ),
                                    ),
                                    activeColor: AppColors.primaryBlue,
                                    checkColor: AppColors.textOnPrimary,
                                    controlAffinity: ListTileControlAffinity.leading,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                    dense: true,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                );
                              }))
                          .toList(),
                  ],
                ),
              ),
            ),
            Container(
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
                onPressed: () => Get.toNamed(Routes.secondStep),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
