import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'dart:io';

import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';

class Elevenstep extends GetView<AuthController> {
  const Elevenstep({super.key});

  @override
  Widget build(BuildContext context) {
    Rx<File?> selectedImage = Rx<File?>(null);

    Future<void> pickImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Business Profile"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: 0.9, // 90% progress
            backgroundColor: Colors.grey[200],
            color: Colors.lightBlue,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Customers prefer pros with a clear profile photo or logo",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Upload a clear image that represents your brand.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Image Upload Box
            Obx(() {
              return GestureDetector(
                onTap: pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: selectedImage.value == null
                      ? const Icon(Icons.camera_alt, size: 40, color: Colors.blue)
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(selectedImage.value!, fit: BoxFit.cover),
                        ),
                ),
              );
            }),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload image"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Pro tip section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.lightbulb, color: Colors.amber),
                      SizedBox(width: 8),
                      Text(
                        "New pro tip",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text("Here's a few images Top Pros used:"),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      4,
                      (index) => Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Save image and go to next step
                  Get.toNamed(Routes.twelvthstep);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Next", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
