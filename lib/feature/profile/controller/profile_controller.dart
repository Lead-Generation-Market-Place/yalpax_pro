import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:logger/web.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yalpax_pro/feature/auth/services/auth_service.dart';
import 'package:yalpax_pro/main.dart';

class ProfileController extends GetxController {
  final supbase = Supabase.instance.client;
  final AuthService authService = Get.find<AuthService>();
  var isLoading = false.obs;
  final ImagePicker _imagePicker = ImagePicker();
  RxInt businessNameLength = 0.obs;
  RxString businessImageUrl = ''.obs;
  RxString businessName = ''.obs;
  TextEditingController businessNameController = TextEditingController();
  @override
  void onInit() async {
    businessNameController.addListener(() {
      businessNameLength.value = businessNameController.text.length;
    });
    super.onInit();
  }

  Future<void> userBusinessProfile() async {
    try {
      isLoading.value = true;
      final response = await supbase
          .from('service_providers')
          .select('image_url,business_name')
          .eq('user_id', authService.userId)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        throw Exception('Error no service provider');
      }

      businessImageUrl.value = response['image_url'];
      businessName.value = response['business_name'];
      businessNameController.text = response['business_name'];
    } catch (e) {
      Logger().e('Error fetching business profile. $e');
    } finally {
      isLoading.value = false;
    }
  }

  void showImagePickerBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Photo'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        await updateBusinessProfile(imageFile);
      }
    } catch (e) {
      Logger().e('Error picking image: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateBusinessProfile(File imageFile) async {
    isLoading.value = true;
    try {
      final userId = authService.userId;
      if (userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      // 1. Delete old image if it exists
      if (businessImageUrl.value.isNotEmpty) {
        try {
          final fullPath = 'logos/${businessImageUrl.value}';
          final response = await supabase.storage.from('business-logos').remove(
            ['logos/${businessImageUrl.value}'],
          );
        } catch (e) {
          Logger().w('Failed to remove old image: $e');
        }
      }
      final folderPath = 'logos';
      // 2. Upload new image
      final fileName =
          '${authService.authUserId.value}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '$folderPath/$fileName';

      await supabase.storage.from('business-logos').upload(filePath, imageFile);

      // 3. Update DB with only fileName (no folder path)
      await supabase
          .from('service_providers')
          .update({'image_url': fileName})
          .eq('user_id', authService.userId);

      businessImageUrl.value = fileName;
      await userBusinessProfile();
      Get.snackbar(
        'Success',
        'Business logo updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Logger().e('Error updating profile image: $e');
      Get.snackbar(
        'Error',
        'Failed to update profile picture',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Timer? _debounce;

  void onBusinessNameChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 800), () {
      if (value.trim().isNotEmpty) {
        saveBusinessName();
      }
    });
  }

  Future<void> saveBusinessName() async {
    try {
      await Supabase.instance.client
          .from('service_providers')
          .update({'business_name': businessNameController.text.trim()})
          .eq('user_id', authService.userId);

      businessName.value = businessNameController.text.trim();
      Logger().i('Business name saved');
    } catch (e) {
      Logger().e('Error saving business name: $e');
      Get.snackbar('Error', 'Failed to save business name');
    }
  }
}
