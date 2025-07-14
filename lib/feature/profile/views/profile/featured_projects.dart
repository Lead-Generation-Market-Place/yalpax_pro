import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/web.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/core/widgets/advanced_dropdown_field.dart';
import 'package:yalpax_pro/core/widgets/custom_button.dart';
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

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                    final isVideo =
                        imageUrl.toLowerCase().contains('.mp4') ||
                        imageUrl.toLowerCase().contains('.mov') ||
                        imageUrl.toLowerCase().contains('.avi');

                    return GestureDetector(
                      // onTap: () {
                      //   Get.toNamed(
                      //     // Routes.photoVideoPreviewer,
                      //     // arguments: {
                      //     //   'images': images,
                      //     //   'initialIndex': index - 1,
                      //     // },
                      //   // );
                      // },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                  ),
                                );
                              },
                            ),
                          ),
                          if (isVideo)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.play_circle_outline,
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
            const SizedBox(height: 30),

            // Submit Button
            CustomButton(
              text: 'Submit',
              onPressed: () async {
                await profileController.saveFeaturedProject();
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
          // Use the controller's showMediaPickerWithProjectId method
          // Pass 0 as the default featuredProjectId for new projects, or the actual id if available
          profileController.showMediaPickerWithProjectId(0); // Replace 0 with the actual project id if you have it
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
}
