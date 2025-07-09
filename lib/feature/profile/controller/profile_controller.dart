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

  // Business Info Controllers
  final RxString phone = ''.obs;
  final RxString website = ''.obs;
  final RxString address = ''.obs;
  final RxString suite = ''.obs;
  final RxString zipCode = ''.obs;
  final RxString yearFounded = ''.obs;
  final RxString employees = ''.obs;
  final RxString introduction = ''.obs;
  final RxString socialMedia = ''.obs;
  final RxString businessFAQs = ''.obs;

  // Business Info Controllers
  final businessNameController = TextEditingController();
  final yearFoundedController = TextEditingController();
  final employeesController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final suiteController = TextEditingController();
  final socialMedialController = TextEditingController();
  final businessFAQSController = TextEditingController();
  final zipCodeController = TextEditingController();
  final websiteController = TextEditingController();

  // Social Media Controllers
  final facebookController = TextEditingController();
  final twitterController = TextEditingController();
  final instagramController = TextEditingController();
  final introductionController = TextEditingController();

  // Business Info
  RxString businessImageUrl = ''.obs;
  RxString businessName = ''.obs;

  // Payment Methods
  RxList<String> selectedPaymentMethods = <String>[].obs;
  final List<String> availablePaymentMethods = [
    'Credit card',
    'Cash',
    'Venmo',
    'Paypal',
    'Square cash app',
    'Check',
    'Apple Pay',
    'Google Pay',
    'Zelle',
    'Samsung Pay',
    'Stripe',
  ];

  @override
  void onInit() async {
    await userBusinessProfile();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    userBusinessProfile();
  }

  Future<void> userBusinessProfile() async {
  try {
    isLoading.value = true;

    final response = await supabase
        .from('service_providers')
        .select(
          '*, users_profiles(*), provider_locations!inner(location:locations(*))',
        )
        .eq('user_id', authService.userId)
        .eq('provider_locations.is_primary', true)
        .maybeSingle();

    Logger().i(response);

    if (response == null) {
      throw Exception('Error: No service provider found.');
    }

    // Update service_providers related data
    businessImageUrl.value = response['image_url'] ?? '';
    businessName.value = response['business_name'] ?? '';
    yearFoundedController.text = response['founded_year']?.toString() ?? '';
    employeesController.text = response['employees_count']?.toString() ?? '';
    introductionController.text = response['introduction'] ?? '';

    // Sync observables with controller texts
    yearFounded.value = yearFoundedController.text;
    employees.value = employeesController.text;
    introduction.value = introductionController.text;
    businessNameController.text = businessName.value;

    // Update users_profiles data
    final profile = response['users_profiles'];
    if (profile != null) {
      phoneController.text = profile['phone_number'] ?? '';
      websiteController.text = profile['website'] ?? '';
    }

    phone.value = phoneController.text;
    website.value = websiteController.text;

    // Update provider_locations > locations data
    final providerLocations = response['provider_locations'] as List?;
    if (providerLocations != null && providerLocations.isNotEmpty) {
      final location = providerLocations.first['location'];
      if (location != null) {
        addressController.text = location['address_line1'] ?? '';
        suiteController.text = location['address_line2'] ?? '';
        zipCodeController.text = location['zip'] ?? '';
      }
    }

    address.value = addressController.text;
    suite.value = suiteController.text;
    zipCode.value = zipCodeController.text;

  } catch (e) {
    Logger().e('Error fetching business profile: $e');
    Get.snackbar(
      'Error',
      'Failed to fetch business profile',
      snackPosition: SnackPosition.BOTTOM,
    );
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

  Future<void> saveBusinessInfo() async {
    try {
      isLoading.value = true;
      await supbase
          .from('service_providers')
          .update({
            'founded_year': int.tryParse(yearFoundedController.text),
            'employees_count': int.tryParse(employeesController.text),
            'phone_number': phoneController.text,
            'address_line1': addressController.text,
            'suite': suiteController.text,
            'zip_code': zipCodeController.text,
            'website': websiteController.text,
            'payment_methods': selectedPaymentMethods,
            'facebook': facebookController.text,
            'twitter': twitterController.text,
            'instagram': instagramController.text,
          })
          .eq('user_id', authService.userId);

      Get.snackbar(
        'Success',
        'Business information updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Logger().e('Error saving business info: $e');
      Get.snackbar('Error', 'Failed to save business information');
    } finally {
      isLoading.value = false;
    }
  }

  void togglePaymentMethod(String method) {
    if (selectedPaymentMethods.contains(method)) {
      selectedPaymentMethods.remove(method);
    } else {
      selectedPaymentMethods.add(method);
    }
    saveBusinessInfo();
  }
}
