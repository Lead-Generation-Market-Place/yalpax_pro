import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:yalpax_pro/core/constants/app_colors.dart';
import 'package:yalpax_pro/core/widgets/bottom_navbar.dart';
import 'package:yalpax_pro/core/widgets/foldable_widgets.dart';
import 'package:yalpax_pro/feature/jobs/controllers/jobs_controller.dart';
import 'package:yalpax_pro/feature/messages/controllers/messages_controller.dart';

class MessageView extends GetView<MessagesController> {
  const MessageView({super.key});

  @override
  Widget build(BuildContext context) {
    final jobsController jobs_controller = Get.find<jobsController>();

    return Scaffold(
      bottomNavigationBar: BottomNavbar(),
      body: ResponsiveContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search field
              Container(
                height: 40,
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
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.neutral500,
                    ),
                    suffixIcon: Obx(
                      () => controller.showClearButton.value
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: AppColors.neutral500,
                              ),
                              onPressed: controller.clearSearch,
                            )
                          : const SizedBox.shrink(),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Zip code field
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
                    prefixIcon: const Icon(
                      Icons.location_on,
                      color: AppColors.neutral500,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),

              const SizedBox(height: 20),

              // Service list
              Expanded(
                child: Obx(
                  () => controller.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : controller.searchController.text.isEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
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
                                        visualDensity: VisualDensity.compact,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                              vertical: 4.0,
                                            ),
                                        onTap: () async {
                                          if (service['id'] != null) {
                                            // await controller.fetchQuestions(service['id']);
                                            print('Tapped: ${service['name']}');
                                          }
                                        },
                                      ),
                                      Divider(
                                        height: 1,
                                        color: AppColors.neutral200,
                                      ),
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
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 4.0,
                                  ),
                                  onTap: () async {
                                    if (service['id'] != null) {
                                      // await homeController.fetchQuestions(service['id']);
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
            ],
          ),
        ),
      ),
    );
  }
}
