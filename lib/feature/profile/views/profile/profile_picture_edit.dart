import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/constants/app_colors.dart';
import 'package:yalpax_pro/core/constants/file_urls.dart';
import 'package:yalpax_pro/core/widgets/custom_button.dart';
import 'package:yalpax_pro/core/widgets/custom_input.dart';
import 'package:yalpax_pro/feature/profile/controller/profile_controller.dart';

class ProfilePictureEdit extends GetView<ProfileController> {
  ProfilePictureEdit({super.key});
  final formKeyEditProfilePicture = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Basic info',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Profile Image with Edit Icon
              Container(
                width: 180,
                height: 180,

                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Obx(() {
                      final imageUrl = controller.businessImageUrl.value;
                      return Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.neutral100,
                            width: 8,
                          ),
                        ),
                        child: imageUrl.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  "${FileUrls.businessLogo}$imageUrl",
                                  width: 180,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildPlaceholder(context),
                                ),
                              )
                            : _buildPlaceholder(context),
                      );
                    }),
                    GestureDetector(
                      onTap: () {
                        controller.showImagePickerBottomSheet(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
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
              ),
              const SizedBox(height: 16),
              // Change Photo Button
              TextButton(
                onPressed: () {
                  controller.showImagePickerBottomSheet(context);
                },
                child: const Text(
                  'Change photo',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Examples and Tips Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Examples and Tips Header
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.grey[700],
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Examples and tips',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Example Photos
                    SizedBox(
                      height: 70,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 6,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 16),
                        itemBuilder: (context, index) => Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
                            image: DecorationImage(
                              image: AssetImage(
                                'assets/images/${index + 1}.jpg',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Tips List
                    _buildTip('Make sure to smile.'),
                    _buildTip('Take photo in daylight. No flash.'),
                    _buildTip('Use a solid background.'),
                    _buildTip('Hold camera slightly higher than eye level.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Business Name Section
              Form(
                key: formKeyEditProfilePicture,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomInput(
                      hint: 'Enter your business name',
                      label: 'Business Name',
                      autofocus: false,
                      controller: controller.businessNameController,
                      maxLength: 50,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your business name.';
                        } else if (value.length > 50) {
                          return 'Maximum 50 characters allowed.';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        controller.onBusinessNameChanged(value);
                        // Validate on each change
                        formKeyEditProfilePicture.currentState?.validate();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.image, size: 40, color: Colors.white),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Text('•', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}
