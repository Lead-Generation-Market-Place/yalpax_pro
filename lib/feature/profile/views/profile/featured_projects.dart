import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/web.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/core/widgets/advanced_dropdown_field.dart';
import 'package:yalpax_pro/core/widgets/custom_button.dart';
import 'package:yalpax_pro/core/widgets/custom_flutter_toast.dart';
import 'package:yalpax_pro/feature/profile/controller/profile_controller.dart';

class AddProjectPage extends StatefulWidget {
  const AddProjectPage({Key? key}) : super(key: key);

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  final TextEditingController locationController = TextEditingController();
  final TextEditingController projectTitleController = TextEditingController();
  final ProfileController profileController = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    fetchServices();
  }

  Future<void> fetchServices() async {
    try {
      await profileController.fetchServices();
    } catch (e) {
      Logger().d(e);
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && photos.length < 4) {
      setState(() {
        photos.add(image);
      });
    }
  }

  final List<XFile> selectedFiles = [];

  final List<XFile> photos = [];

  Widget buildPhotoPicker(int index) {
    return GestureDetector(
      onTap: pickImage,
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: photos.length > index
            ? Image.file(File(photos[index].path), fit: BoxFit.cover)
            : const Icon(Icons.image_outlined, size: 40, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add project"),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "New Project",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Service Dropdown
            Obx(
              () => AdvancedDropdownField<Map<String, dynamic>>(
                label: "Service",
                hint: "Select a service",
                items: profileController.services,
                selectedValue: profileController.services.firstWhereOrNull(
                  (service) =>
                      service['id'].toString() ==
                      profileController.selectedServiceId.value,
                ),
                getLabel: (service) => service['name'].toString(),
                onChanged: (service) {
                  if (service != null) {
                    profileController.selectedServiceId.value = service['id']
                        .toString();
                  }
                },
                isRequired: true,
              ),
            ),
            const SizedBox(height: 20),

            // Location
            const Text("Location (optional)"),
            const SizedBox(height: 5),
            Autocomplete<Map<String, dynamic>>(
              initialValue: TextEditingValue(text: locationController.text),
              optionsBuilder: (TextEditingValue textEditingValue) async {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<Map<String, dynamic>>.empty();
                }
                await profileController.searchCities(textEditingValue.text);
                return profileController.citySearchResults;
              },
              displayStringForOption: (Map<String, dynamic> option) =>
                  option['city'],
              onSelected: (Map<String, dynamic> selection) {
                profileController.selectedCityId.value = selection['id'];
                locationController.text = selection['city'];
              },
              fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  onFieldSubmitted: (_) => onSubmitted(),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    hintText: "Enter city",
                    border: const OutlineInputBorder(),
                    suffixIcon: Obx(() {
                      if (profileController.isCitySearching.value) {
                        return const SizedBox(
                          width: 20,
                          height: 20,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ),
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    child: Container(
                      width: MediaQuery.of(context).size.width - 32,
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options.elementAt(index);
                          return ListTile(
                            title: Text(option['city']),
                            onTap: () => onSelected(option),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Project title
            const Text("Project title"),
            const SizedBox(height: 5),
            TextFormField(
              controller: projectTitleController,
              decoration: const InputDecoration(
                hintText: "Example: Outdoor beach wedding",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Photos
            Obx(() {
              final images = profileController.featureProjectImageUrls;
              final allFiles = [...selectedFiles.map((e) => e.path), ...images];

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: allFiles.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildAddPhotoButton();
                  } else {
                    final filePath = allFiles[index - 1];
                    final isVideo =
                        filePath.toLowerCase().endsWith('.mp4') ||
                        filePath.toLowerCase().endsWith('.mov') ||
                        filePath.toLowerCase().endsWith('.avi');

                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        isVideo
                            ? Container(
                                color: Colors.black12,
                                child: const Center(
                                  child: Icon(
                                    Icons.play_circle_outline,
                                    size: 40,
                                  ),
                                ),
                              )
                            : Image.file(
                                File(filePath),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                              ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedFiles.removeWhere(
                                  (file) => file.path == filePath,
                                );
                                profileController.featureProjectImageUrls
                                    .remove(filePath);
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              );
            }),

            const SizedBox(height: 30),

            // Submit Button
            CustomButton(
              text: 'Submit',
              onPressed: () async {
                final title = projectTitleController.text.trim();
                final serviceId = profileController.selectedServiceId.value;
                final cityId =
                    profileController.selectedCityId.value;

                if (selectedFiles.isEmpty) {
                  CustomFlutterToast.showErrorToast(
                    'Please select at least one media file',
                  );
                  return;
                }

                if (title.isEmpty || serviceId.isEmpty) {
                  CustomFlutterToast.showErrorToast(
                    'Title and service are required',
                  );
                  return;
                }

                await profileController.saveFeaturedProjectAndFiles(
                  selectedFiles: selectedFiles,
                  projectTitle: title,
                  serviceId: serviceId,
                  cityId: cityId,
                );
              },
            ),
          ],
        ),
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
        onTap: () {
          _showImagePickerBottomSheet(context);
        },
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
                          await pickMedia(
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
                          await pickMedia(
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
                          await pickMedia(
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
                          await pickMedia(
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

  Future<void> pickMedia({
    required ImageSource source,
    required bool isVideo,
  }) async {
    try {
      bool permissionGranted = false;

      // Request permissions
      if (source == ImageSource.camera) {
        final status = await Permission.camera.request();
        permissionGranted = status.isGranted;
        if (status.isPermanentlyDenied) {
          await _showPermissionSettingsDialog('Camera');
          return;
        }
      } else {
        if (Platform.isAndroid) {
          final status = await Permission.storage.request();
          permissionGranted = status.isGranted;
          if (status.isPermanentlyDenied) {
            await _showPermissionSettingsDialog('Storage');
            return;
          }
        } else if (Platform.isIOS) {
          final status = await Permission.photos.request();
          permissionGranted = status.isGranted;
          if (status.isPermanentlyDenied) {
            await _showPermissionSettingsDialog('Photos');
            return;
          }
        }
      }

      if (!permissionGranted) {
        Get.snackbar(
          'Permission Denied',
          'Please grant permission to access ${source == ImageSource.camera ? 'camera' : 'gallery'}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
        return;
      }

      if (isVideo) {
        final XFile? video = await ImagePicker().pickVideo(source: source);

        if (video != null) {
          final File videoFile = File(video.path);
          final int fileSize = await videoFile.length();
          if (fileSize > 10 * 1024 * 1024) {
            CustomFlutterToast.showErrorToast(
              'Video size must be less than 10MB',
            );
            return;
          }

          setState(() {
            selectedFiles.add(video); // Add video to selectedFiles
          });
        }
      } else {
        final List<XFile>? images = source == ImageSource.gallery
            ? await ImagePicker().pickMultiImage(
                maxHeight: 1200,
                maxWidth: 1200,
                imageQuality: 85,
              )
            : [
                await ImagePicker().pickImage(
                  source: source,
                  maxHeight: 1200,
                  maxWidth: 1200,
                  imageQuality: 85,
                ),
              ].whereType<XFile>().toList();

        if (images != null && images.isNotEmpty) {
          for (var image in images) {
            final File imageFile = File(image.path);
            final int fileSize = await imageFile.length();
            if (fileSize > 1 * 1024 * 1024) {
              CustomFlutterToast.showErrorToast(
                'Image size must be less than 1MB',
              );
              continue;
            }
            setState(() {
              selectedFiles.add(image); // Add image to selectedFiles
            });
          }
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick file: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  Future<void> _showPermissionSettingsDialog(String permissionType) async {
    await Get.dialog(
      AlertDialog(
        title: Text('$permissionType Permission Required'),
        content: Text(
          'We need $permissionType permission to proceed. Please enable it in settings.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
