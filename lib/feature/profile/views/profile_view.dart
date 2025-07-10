import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/constants/file_urls.dart';
import 'package:yalpax_pro/core/widgets/bottom_navbar.dart';
import 'package:yalpax_pro/core/constants/app_colors.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/core/widgets/custom_app_bar.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';
import 'package:yalpax_pro/feature/profile/controller/profile_controller.dart';
import 'package:yalpax_pro/feature/jobs/controllers/jobs_controller.dart';

class ProfileView extends GetView<ProfileController> {
  ProfileView({super.key});
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final JobsController jobsController = Get.find<JobsController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: 'Profile', showSetupBanner: true),
      bottomNavigationBar: BottomNavbar(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewPadding.bottom + 80,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.calendar_today,
                              color: AppColors.neutral700,
                            ),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.settings,
                              color: AppColors.neutral700,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.toNamed(Routes.editProfilePicture);
                            },
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.edit,
                                  color: AppColors.primaryBlue,
                                  size: 20,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Edit',
                                  style: TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.neutral100,
                                width: 4,
                              ),
                            ),
                            child: Obx(() {
                              final imageUrl =
                                  controller.businessImageUrl.value;
                              return ClipOval(
                                child: imageUrl.isNotEmpty
                                    ? Image.network(
                                        "${FileUrls.businessLogo}$imageUrl",
                                        width: 180,
                                        height: 180,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                _buildPlaceholder(),
                                      )
                                    : _buildPlaceholder(),
                              );
                            }),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.toNamed(Routes.editProfilePicture);
                              controller.showImagePickerBottomSheet(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${authController.name}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(() {
                        return Text(
                          controller.businessName.value,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(
                              color: AppColors.primaryBlue,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'See how you rank',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Preview profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Business info',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Obx(
                        () => _buildInfoItem(
                          icon: Icons.phone,
                          title: 'Phone Number',
                          value: controller.phone.value.isNotEmpty
                              ? controller.phone.value
                              : 'Add phone',
                          isPlaceholder: controller.phone.value.isEmpty,
                          routeName: Routes.businessInfo,
                        ),
                      ),
                      Obx(
                        () => _buildInfoItem(
                          icon: Icons.language,
                          title: 'Website',
                          value: controller.website.value.isNotEmpty
                              ? controller.website.value
                              : 'Add website',
                          isPlaceholder: controller.website.value.isEmpty,
                          routeName: Routes.businessInfo,
                        ),
                      ),
                      Obx(
                        () => _buildInfoItem(
                          icon: Icons.location_on,
                          title: 'Address',
                          value: controller.address.value.isNotEmpty
                              ? controller.address.value
                              : 'Add address',
                          isPlaceholder: controller.address.value.isEmpty,
                          routeName: Routes.businessInfo,
                        ),
                      ),
                      Obx(
                        () => _buildInfoItem(
                          icon: Icons.calendar_today,
                          title: 'Year Founded',
                          value: controller.yearFounded.value.isNotEmpty
                              ? controller.yearFounded.value
                              : 'Add year',
                          isPlaceholder: controller.yearFounded.value.isEmpty,
                          routeName: Routes.businessInfo,
                        ),
                      ),
                      Obx(
                        () => _buildInfoItem(
                          icon: Icons.group,
                          title: 'Number of Employees',
                          value: controller.employees.value.isNotEmpty
                              ? controller.employees.value
                              : 'Add count',
                          isPlaceholder: controller.employees.value.isEmpty,
                          routeName: Routes.businessInfo,
                        ),
                      ),
                      Obx(
                        () => _buildInfoItem(
                          icon: Icons.share,
                          title: 'Social Media',
                          value: controller.socialMedia.value.isNotEmpty
                              ? controller.socialMedia.value
                              : 'Add social media',
                          isPlaceholder: controller.socialMedia.value.isEmpty,
                          routeName: Routes.businessInfo,
                        ),
                      ),
                      Obx(
                        () => _buildInfoItem(
                          icon: Icons.question_answer,
                          title: 'Business FAQs',
                          value: controller.businessFAQs.value.isNotEmpty
                              ? controller.businessFAQs.value
                              : 'Add FAQs',
                          isPlaceholder: controller.businessFAQs.value.isEmpty,
                          routeName: Routes.businessFAQS,
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your introduction',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.toNamed(Routes.yourIntroduction);
                            },
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.edit,
                                  color: AppColors.primaryBlue,
                                  size: 20,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Edit',
                                  style: TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    bool isPlaceholder = false,
    String? routeName,
    Object? arguments,
  }) {
    return InkWell(
      onTap: routeName != null
          ? () => Get.toNamed(routeName, arguments: arguments)
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(icon, color: AppColors.neutral700),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isPlaceholder
                  ? AppColors.textTertiary
                  : AppColors.textSecondary,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.neutral700,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.neutral100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 32, color: AppColors.neutral400),
            const SizedBox(height: 8),
            Text(
              'Add Logo',
              style: TextStyle(fontSize: 14, color: AppColors.neutral600),
            ),
          ],
        ),
      ),
    );
  }
}
