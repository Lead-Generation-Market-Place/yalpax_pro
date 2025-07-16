import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/web.dart';
import 'package:yalpax_pro/core/constants/file_urls.dart';
import 'package:yalpax_pro/core/widgets/bottom_navbar.dart';
import 'package:yalpax_pro/core/constants/app_colors.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/core/widgets/custom_button.dart';

import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';
import 'package:yalpax_pro/feature/profile/controller/profile_controller.dart';
import 'package:yalpax_pro/feature/jobs/controllers/jobs_controller.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final AuthController authController = Get.find<AuthController>();
  final ProfileController controller = Get.find<ProfileController>();
  final JobsController jobsController = Get.find<JobsController>();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        jobsController.checkStep();
        await controller.userBusinessProfile();
        await controller.fetchUserImages();
        await controller.fetchFeaturedProjects();
      });
    } catch (e) {
      Logger().e(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: BottomNavbar(),
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
                              fontFamily: 'Poppins',
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
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewPadding.bottom + 10,
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
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => _buildPlaceholder(),
                                            )
                                          : _buildPlaceholder(),
                                    );
                                  }),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Get.toNamed(Routes.editProfilePicture);
                                    controller.showImagePickerBottomSheet(
                                      context,
                                    );
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
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
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
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
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
                                isPlaceholder:
                                    controller.yearFounded.value.isEmpty,
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
                                isPlaceholder:
                                    controller.employees.value.isEmpty,
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
                                isPlaceholder:
                                    controller.socialMedia.value.isEmpty,
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
                                isPlaceholder:
                                    controller.businessFAQs.value.isEmpty,
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

                            const SizedBox(height: 35),

                            Container(
                              padding: const EdgeInsets.all(16),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(
                                        Icons.person_outline,
                                        color: AppColors.neutral700,
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Credentials',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Add a background check badge to your profile by getting a check from our third party website checker. This`ll help you win customer`s trust and get hired more.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  TextButton(
                                    onPressed: () {
                                      // Get.toNamed(Routes.businessProfileLicense);
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: const BorderSide(
                                          color: AppColors.primaryBlue,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      'Start a background check',
                                      style: TextStyle(
                                        color: AppColors.primaryBlue,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(16),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(
                                        Icons.person_outline,
                                        color: AppColors.neutral700,
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Professional license',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  /// Reactive section
                                  Obx(() {
                                    if (!controller
                                        .isBusinessLicenseExists
                                        .value) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Customers prefer to hire licensed professionals. If you don\'t already have a license, we recommend that you get one.',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AppColors.textSecondary,
                                              height: 1.5,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          TextButton(
                                            onPressed: () {
                                              Get.toNamed(
                                                Routes.businessProfileLicense,
                                              );
                                            },
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                side: const BorderSide(
                                                  color: AppColors.primaryBlue,
                                                ),
                                              ),
                                            ),
                                            child: const Text(
                                              'Add a license',
                                              style: TextStyle(
                                                color: AppColors.primaryBlue,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${controller.selectedLicenseType.value.isNotEmpty ? controller.selectedLicenseType.value : 'N/A'} • ${controller.licenseNumberController.text.isNotEmpty ? controller.licenseNumberController.text : 'N/A'}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Obx(() {
                                              return Text(
                                                controller
                                                    .businessLicenseStatus
                                                    .value,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              );
                                            }),
                                          ),
                                        ],
                                      );
                                    }
                                  }),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// Title Row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Photos & Videos',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () {
                                          Get.toNamed(Routes.PhotosVideos);
                                        },
                                        icon: const Icon(
                                          Icons.edit,
                                          color: AppColors.primaryBlue,
                                          size: 18,
                                        ),
                                        label: const Text(
                                          'Edit',
                                          style: TextStyle(
                                            color: AppColors.primaryBlue,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  Obx(() {
                                    final images = controller.userImageUrls;

                                    return GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount:
                                          images.length +
                                          1, // Add button + all images
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            mainAxisSpacing: 12,
                                            crossAxisSpacing: 12,
                                            childAspectRatio: 1,
                                          ),
                                      itemBuilder: (context, index) {
                                        if (index == 0) {
                                          // Add Photo Button
                                          return GestureDetector(
                                            onTap: () {
                                              Get.toNamed(Routes.PhotosVideos);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.add_circle_outline,
                                                  color: Colors.blue,
                                                  size: 36,
                                                ),
                                              ),
                                            ),
                                          );
                                        } else {
                                          final imageUrl = images[index - 1];
                                          final isVideo =
                                              imageUrl.toLowerCase().contains(
                                                '.mp4',
                                              ) ||
                                              imageUrl.toLowerCase().contains(
                                                '.mov',
                                              ) ||
                                              imageUrl.toLowerCase().contains(
                                                '.avi',
                                              );

                                          return GestureDetector(
                                            onTap: () {
                                              Get.toNamed(
                                                Routes.photoVideoPreviewer,
                                                arguments: {
                                                  'images': images,
                                                  'initialIndex': index - 1,
                                                },
                                              );
                                            },
                                            child: Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.network(
                                                    imageUrl,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          _,
                                                          __,
                                                          ___,
                                                        ) => const Icon(
                                                          Icons.broken_image,
                                                        ),
                                                    loadingBuilder:
                                                        (
                                                          context,
                                                          child,
                                                          loadingProgress,
                                                        ) {
                                                          if (loadingProgress ==
                                                              null)
                                                            return child;
                                                          return const Center(
                                                            child:
                                                                CircularProgressIndicator(),
                                                          );
                                                        },
                                                  ),
                                                ),
                                                if (isVideo)
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.black
                                                          .withOpacity(0.3),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons
                                                            .play_circle_outline,
                                                        color: Colors.white,
                                                        size: 32,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  }),

                                  const SizedBox(height: 24),

                                  /// Info box
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Show off your business',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Include photos of your work (before and after), team, workspace, or equipment.',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        ElevatedButton(
                                          onPressed: () {
                                            Get.toNamed(Routes.PhotosVideos);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.primaryBlue,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                          child: const Text(
                                            'Add photos',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 25),

                            Obx(() {
                              final projects = controller.featuredProjects;
                              return Container(
                                padding: const EdgeInsets.all(16),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'Featured Projects',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const Spacer(),
                                        TextButton.icon(
                                          onPressed: () {
                                            Get.toNamed(
                                              Routes.featuredProjects,
                                            );
                                          },
                                          label: const Text('Add project'),
                                          icon: const Icon(
                                            Icons.add_circle_outline_rounded,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    projects.isEmpty
                                        ? Container(
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.all(80),
                                            decoration: BoxDecoration(
                                              border: Border.all(width: 0.3),
                                            ),
                                            child: IconButton(
                                              onPressed: () {
                                                Get.toNamed(
                                                  Routes.featuredProjects,
                                                );
                                              },
                                              icon: const Icon(
                                                Icons
                                                    .add_circle_outline_rounded,
                                              ),
                                            ),
                                          )
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: projects.length,
                                            itemBuilder: (context, index) {
                                              final project = projects[index];
                                              return Card(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                    ),
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Icon(
                                                        Icons.work_history,
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        project['project_title'] ??
                                                            'No Title',
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Container(
                                                        margin:
                                                            const EdgeInsets.only(
                                                              left: 20,
                                                            ),
                                                        child: IconButton(
                                                          icon: const Icon(
                                                            Icons.edit,
                                                          ),
                                                          onPressed: () {
                                                            Get.toNamed(
                                                              Routes
                                                                  .featuredProjects,
                                                              arguments: {
                                                                'project':
                                                                    project,
                                                              },
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
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
