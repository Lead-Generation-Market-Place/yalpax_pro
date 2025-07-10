import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:logger/web.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/core/widgets/custom_flutter_toast.dart';
import 'package:yalpax_pro/core/widgets/show_toast.dart';
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

  final firstBusinessQuestion = TextEditingController();
  final firstBusinessCharCount = 0.obs;
  final hasTypedFirstBusiness = false.obs;
  final secondtBusinessQuestion = TextEditingController();
  final secondBusinessCharCount = 0.obs;
  final hasTypedSecondBusiness = false.obs;
  final thirdBusinessQuestion = TextEditingController();
  final thirdBusinessCharCount = 0.obs;
  final hasTypedThirdBusiness = false.obs;
  final fourthBusinessQuestion = TextEditingController();
  final fourthBusinessCharCount = 0.obs;
  final hasTypedFourthBusiness = false.obs;
  final fifthBusinessQuestion = TextEditingController();
  final fifthBusinessCharCount = 0.obs;
  final hasTypedFifthBusiness = false.obs;
  final sixthBusinessQuestion = TextEditingController();
  final sixthBusinessCharCount = 0.obs;
  final hasTypedSixthBusiness = false.obs;
  final seventhBusinessQuestion = TextEditingController();
  final seventhBusinessCharCount = 0.obs;
  final hasTypedSeventhBusiness = false.obs;
  final eightBusinessQuestion = TextEditingController();
  final eighthBusinessCharCount = 0.obs;
  final hasTypedEighthBusiness = false.obs;
  final ningthBusinessQuestion = TextEditingController();
  final ninthBusinessCharCount = 0.obs;
  final hasTypedNinthBusiness = false.obs;

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
    firstBusinessQuestion.addListener(() {
      hasTypedFirstBusiness.value = true;
      firstBusinessCharCount.value = firstBusinessQuestion.text.length;
    });
    secondtBusinessQuestion.addListener(() {
      hasTypedSecondBusiness.value = true;
      secondBusinessCharCount.value = secondtBusinessQuestion.text.length;
    });
    thirdBusinessQuestion.addListener(() {
      hasTypedThirdBusiness.value = true;
      thirdBusinessCharCount.value = thirdBusinessQuestion.text.length;
    });
    fourthBusinessQuestion.addListener(() {
      hasTypedFourthBusiness.value = true;
      fourthBusinessCharCount.value = fourthBusinessQuestion.text.length;
    });
    fifthBusinessQuestion.addListener(() {
      hasTypedFifthBusiness.value = true;
      fifthBusinessCharCount.value = fifthBusinessQuestion.text.length;
    });
    sixthBusinessQuestion.addListener(() {
      hasTypedSixthBusiness.value = true;
      sixthBusinessCharCount.value = sixthBusinessQuestion.text.length;
    });
    seventhBusinessQuestion.addListener(() {
      hasTypedSeventhBusiness.value = true;
      secondBusinessCharCount.value = seventhBusinessQuestion.text.length;
    });
    eightBusinessQuestion.addListener(() {
      hasTypedEighthBusiness.value = true;
      eighthBusinessCharCount.value = eightBusinessQuestion.text.length;
    });
    ningthBusinessQuestion.addListener(() {
      hasTypedNinthBusiness.value = true;
      ninthBusinessCharCount.value = ningthBusinessQuestion.text.length;
    });

    super.onInit();
  }

  @override
  void onClose() {
    firstBusinessQuestion.dispose();
    secondtBusinessQuestion.dispose();
    thirdBusinessQuestion.dispose();
    fourthBusinessQuestion.dispose();
    fifthBusinessQuestion.dispose();
    sixthBusinessQuestion.dispose();
    seventhBusinessQuestion.dispose();
    eightBusinessQuestion.dispose();
    ningthBusinessQuestion.dispose();
    super.onClose();
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
          .maybeSingle()
          .limit(1);

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
      // Payment methods
      final paymentString = response['payment_methods'] ?? '';
      selectedPaymentMethods.value = (paymentString as String)
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      // Social media
      facebookController.text = response['facebook'] ?? '';
      twitterController.text = response['twitter'] ?? '';
      instagramController.text = response['instagram'] ?? '';
      websiteController.text = response['website'] ?? '';

      // Sync observables with controller texts
      yearFounded.value = yearFoundedController.text;
      employees.value = employeesController.text;
      introduction.value = introductionController.text;
      businessNameController.text = businessName.value;

      // Update users_profiles data
      final profile = response['users_profiles'];
      if (profile != null) {
        phoneController.text = profile['phone_number'] ?? '';
        employeesController.text =
            response['employees_count']?.toString() ?? '';
        employees.value = employeesController.text;
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

  Future<void> saveBusinessIntroduction() async {
    try {
      isLoading.value = true;
      final response = await supabase
          .from('service_providers')
          .update({'introduction': introductionController.text})
          .eq('user_id', authService.userId);

      if (response != null) {
        throw Exception('Error updating introduction.');
      }
      Get.toNamed(Routes.profile);

      await userBusinessProfile();
    } catch (e) {
      Logger().e('Error saving business introduction.');
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

      // Step 1: Update phone number in users_profiles
      final phoneNumberResponse = await supabase
          .from('users_profiles')
          .update({'phone_number': phoneController.text})
          .eq('id', authService.userId);

      if (phoneNumberResponse != null) {
        throw Exception('Error updating phone number');
      }

      // Step 2: Update service_providers table and get provider_id
      final serviceProviderResponse = await supabase
          .from('service_providers')
          .update({
            'founded_year': int.tryParse(yearFoundedController.text),
            'employees_count': int.tryParse(employeesController.text),
            'website': websiteController.text,
            'payment_methods': selectedPaymentMethods.join(','),
            'facebook': facebookController.text,
            'twitter': twitterController.text,
            'instagram': instagramController.text,
          })
          .eq('user_id', authService.userId)
          .select('provider_id');

      if (serviceProviderResponse.isEmpty) {
        throw Exception('Error updating business info');
      }

      final providerId = serviceProviderResponse[0]['provider_id'];

      // Step 3: Get the location_id (via provider_locations)
      final providerLocation = await supabase
          .from('provider_locations')
          .select('state_id')
          .eq('provider_id', providerId)
          .limit(1);

      if (providerLocation.isEmpty) {
        throw Exception('No provider location found');
      }

      final locationId = providerLocation[0]['state_id'];

      // Step 4: Update locations table
      final locationUpdate = await supabase
          .from('locations')
          .update({
            'address_line1': addressController.text,
            'address_line2': suiteController.text,
            'zip': zipCodeController.text,
          })
          .eq('id', locationId);

      if (locationUpdate != null) {
        throw Exception('Error updating location');
      }
      // Show success message
      CustomFlutterToast.showSuccessToast(
        'Business information updated successfully',
      );
      Get.toNamed(Routes.profile);
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
  }

  Future<void> answeredBusinessFaqsQuestion() async {
    try {
      isLoading.value = true;

      // 1. Check if a record already exists for this user
      final existing = await supabase
          .from('business_faqs')
          .select('id')
          .eq('user_id', authService.userId)
          .limit(1)
          .maybeSingle();

      if (existing == null) {
        // 2. INSERT new record with a manually generated UUID
        final uuid = Uuid();
        final insertResponse = await supabase.from('business_faqs').insert({
          'id': uuid.v4(),
          'user_id': authService.userId,
          'first_question': firstBusinessQuestion.text,
          'second_question': secondtBusinessQuestion.text,
          'third_question': thirdBusinessQuestion.text,
          'fourth_question': fourthBusinessQuestion.text,
          'fifth_question': fifthBusinessQuestion.text,
          'sixth_question': sixthBusinessQuestion.text,
          'seventh_question': seventhBusinessQuestion.text,
          'eight_question': eightBusinessQuestion.text,
        });

        if (insertResponse != null) {
          throw Exception('Failed to insert new business FAQ.');
        }
      } else {
        // 3. UPDATE existing record
        final updateResponse = await supabase
            .from('business_faqs')
            .update({
              'first_question': firstBusinessQuestion.text,
              'second_question': secondtBusinessQuestion.text,
              'third_question': thirdBusinessQuestion.text,
              'fourth_question': fourthBusinessQuestion.text,
              'fifth_question': fifthBusinessQuestion.text,
              'sixth_question': sixthBusinessQuestion.text,
              'seventh_question': seventhBusinessQuestion.text,
              'eight_question': eightBusinessQuestion.text,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('user_id', authService.userId);

        if (updateResponse != null) {
          throw Exception('Failed to update business FAQ.');
        }
      }

      // 4. Navigate and reload
      Get.toNamed(Routes.profile);
      await userBusinessProfile();
    } catch (e) {
      Logger().e(e);
    } finally {
      isLoading.value = false;
    }
  }

  bool hasLoadedFaqs = false;
  Future<void> fetchAnsweredBusinessFaqs() async {
    try {
      isLoading.value = true;

      // Fetch the record for the current user
      final response = await supabase
          .from('business_faqs')
          .select('''
          first_question,
          second_question,
          third_question,
          fourth_question,
          fifth_question,
          sixth_question,
          seventh_question,
          eight_question
          ''')
          .eq('user_id', authService.userId)
          .maybeSingle();

      if (response == null) {
        Logger().i('No business FAQs found for this user.');
        return;
      }

      // Fill your text controllers or observable variables
      firstBusinessQuestion.text = response['first_question'] ?? '';
      secondtBusinessQuestion.text = response['second_question'] ?? '';
      thirdBusinessQuestion.text = response['third_question'] ?? '';
      fourthBusinessQuestion.text = response['fourth_question'] ?? '';
      fifthBusinessQuestion.text = response['fifth_question'] ?? '';
      sixthBusinessQuestion.text = response['sixth_question'] ?? '';
      seventhBusinessQuestion.text = response['seventh_question'] ?? '';
      eightBusinessQuestion.text = response['eight_question'] ?? '';

      Logger().i('Business FAQs loaded successfully');
    } catch (e) {
      Logger().e('Error fetching business FAQs: $e');
      Get.snackbar('Error', 'Failed to fetch FAQ answers');
    } finally {
      isLoading.value = false;
    }
  }
}
