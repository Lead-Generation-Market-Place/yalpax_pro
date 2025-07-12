import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/core/widgets/custom_button.dart';
import 'package:yalpax_pro/feature/jobs/controllers/jobs_controller.dart';
import 'package:yalpax_pro/feature/profile/controller/profile_controller.dart';

class PhotosVideos extends GetView<ProfileController> {
  const PhotosVideos({super.key});

  @override
  Widget build(BuildContext context) {
    final jobsController = Get.find<JobsController>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
     await controller.fetchUserImages();
    });

    return Scaffold(
      backgroundColor: Colors.white,
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

            // AppBar-like row with elevation
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Get.back(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Photos & Videos',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Photo suggestions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSuggestionItem(
                            Icons.compare_arrows,
                            'Your work (before and after)',
                          ),
                          _buildSuggestionItem(
                            Icons.person_outline,
                            'You on the job',
                          ),
                          _buildSuggestionItem(
                            Icons.work_outline,
                            'Equipment or workspace',
                          ),
                          _buildSuggestionItem(
                            Icons.people_outline,
                            'Team or co-workers',
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Press and hold photos to drag and rearrange.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Photo Grid Section
                    Obx(() {
                      final images = controller.userImageUrls;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: images.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _buildAddPhotoButton();
                          } else {
                            final imageUrl = images[index - 1];
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
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          }
                        },
                      );
                    }),

                    // Photo Suggestions Section
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: InkWell(
        onTap: () => _showImagePickerBottomSheet(Get.context!),
        child: Center(
          child: Icon(
            Icons.add_circle_outline,
            size: 32,
            color: Colors.blue[400],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 32, color: Colors.grey),
      ),
    );
  }

  void _showImagePickerBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add Photos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 20),
            _buildOptionTile(
              icon: Icons.photo_library_outlined,
              title: 'Choose from Gallery',
              onTap: () async {
                Get.back(); // Close the bottom sheet

                await Get.defaultDialog(
                  title: 'Select Media Type',
                  content: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.image),
                        title: const Text('Image'),
                        onTap: () async {
                          Get.back(); // Close dialog
                          await controller.pickMedia(
                            source: ImageSource.gallery,
                            isVideo: false,
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.videocam),
                        title: const Text('Video'),
                        onTap: () async {
                          Get.back(); // Close dialog
                          await controller.pickMedia(
                            source: ImageSource.gallery,
                            isVideo: true,
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            _buildOptionTile(
              icon: Icons.camera_alt_outlined,
              title: 'Take a Photo or Video',
              onTap: () async {
                Get.back(); // Close the bottom sheet

                await Get.defaultDialog(
                  title: 'Select Media Type',
                  content: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.photo_camera),
                        title: const Text('Photo'),
                        onTap: () async {
                          Get.back(); // Close dialog
                          await controller.pickMedia(
                            source: ImageSource.camera,
                            isVideo: false,
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.videocam),
                        title: const Text('Video'),
                        onTap: () async {
                          Get.back(); // Close dialog
                          await controller.pickMedia(
                            source: ImageSource.camera,
                            isVideo: true,
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue[400], size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
