import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:logger/web.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
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

  // Services variables
  RxList<Map<String, dynamic>> services = <Map<String, dynamic>>[].obs;
  RxString selectedServiceId = ''.obs;

  // City search variables
  RxList<Map<String, dynamic>> citySearchResults = <Map<String, dynamic>>[].obs;
  RxBool isCitySearching = false.obs;

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

  // Professional License Variables

  @override
  void onInit() async {
    // await fetchUserImages();

    // firstBusinessQuestion.addListener(() {
    //   hasTypedFirstBusiness.value = true;
    //   firstBusinessCharCount.value = firstBusinessQuestion.text.length;
    // });
    // secondtBusinessQuestion.addListener(() {
    //   hasTypedSecondBusiness.value = true;
    //   secondBusinessCharCount.value = secondtBusinessQuestion.text.length;
    // });
    // thirdBusinessQuestion.addListener(() {
    //   hasTypedThirdBusiness.value = true;
    //   thirdBusinessCharCount.value = thirdBusinessQuestion.text.length;
    // });
    // fourthBusinessQuestion.addListener(() {
    //   hasTypedFourthBusiness.value = true;
    //   fourthBusinessCharCount.value = fourthBusinessQuestion.text.length;
    // });
    // fifthBusinessQuestion.addListener(() {
    //   hasTypedFifthBusiness.value = true;
    //   fifthBusinessCharCount.value = fifthBusinessQuestion.text.length;
    // });
    // sixthBusinessQuestion.addListener(() {
    //   hasTypedSixthBusiness.value = true;
    //   sixthBusinessCharCount.value = sixthBusinessQuestion.text.length;
    // });
    // seventhBusinessQuestion.addListener(() {
    //   hasTypedSeventhBusiness.value = true;
    //   secondBusinessCharCount.value = seventhBusinessQuestion.text.length;
    // });
    // eightBusinessQuestion.addListener(() {
    //   hasTypedEighthBusiness.value = true;
    //   eighthBusinessCharCount.value = eightBusinessQuestion.text.length;
    // });
    // ningthBusinessQuestion.addListener(() {
    //   hasTypedNinthBusiness.value = true;
    //   ninthBusinessCharCount.value = ningthBusinessQuestion.text.length;
    // });
    licenseNumberController.addListener(() {
      update();
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
    licenseNumberController.dispose();
    super.onClose();
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
          final addressLine1 = location['address_line1'] ?? '';
          final addressLine2 = location['address_line2'] ?? '';
          address.value = [
            addressLine1,
            addressLine2,
          ].where((line) => line.isNotEmpty).join(', ');

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

        final insertResponse = await supabase.from('business_faqs').insert({
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

  Future<void> saveProfessionalLicense() async {
    try {
      isLoading.value = true;

      if (selectedState.isEmpty ||
          selectedLicenseType.isEmpty ||
          licenseNumberController.text.isEmpty) {
        throw Exception('Please fill in all fields');
      }

      final provider = await supabase
          .from('service_providers')
          .select('provider_id')
          .eq('user_id', authService.userId)
          .select()
          .limit(1);

      if (provider == null) {
        throw Exception('Error fetching provider id');
      }
      // Ensure we have the correct license ID
      if (selectedLicenseTypeId.value.isEmpty) {
        final selected = licenseTypeOptions.firstWhereOrNull(
          (item) => item['name'] == selectedLicenseType.value,
        );
        selectedLicenseTypeId.value = selected?['id'] ?? '';
      }

      final response = await supabase
          .from(
            'provider_license',
          ) // saving to provider_license as per your latest instruction
          .insert({
            'provider_id': provider[0]['provider_id'],
            'state_id': selectedState
                .value, // optionally use selectedStateId if you're mapping states too
            'license_id': selectedLicenseTypeId.value,
            'license_number': licenseNumberController.text,
          })
          .select()
          .single();

      if (response.isEmpty) {
        throw Exception('Failed to save license information');
      }

      CustomFlutterToast.showSuccessToast(
        'License information saved successfully',
      );
      Get.offAndToNamed(Routes.profile);
    } catch (e) {
      Logger().e('Error saving professional license: $e');
      CustomFlutterToast.showErrorToast('Failed to save license information');
    } finally {
      isLoading.value = false;
    }
  }

  RxString businessLicenseStatus = ''.obs;
  var isBusinessLicenseExists = false.obs;
  Future<bool> fetchProfessionalLicense() async {
    try {
      isLoading.value = true;

      final providerData = await supabase
          .from('service_providers')
          .select('provider_id')
          .eq('user_id', authService.userId)
          .maybeSingle(); // Use maybeSingle here to get a single map

      final providerId = providerData?['provider_id'];

      if (providerId == null) {
        Logger().w('No provider ID found for user.');
        return false;
      }

      final response = await supabase
          .from('provider_license')
          .select()
          .eq('provider_id', providerId)
          .maybeSingle();

      final licenseResponse = await supabase
          .from('licenses')
          .select('name')
          .eq('id', response?['license_id']);

      if (response != null) {
        selectedState.value = response['state'] ?? '';
        selectedLicenseType.value = licenseResponse[0]['name'] ?? '';
        licenseNumberController.text = response['license_number'] ?? '';
        businessLicenseStatus.value = response['busines_licens_status'] ?? '';
        // licenseStatus.text = response['licenseStatus'] ?? '';
      }
      isBusinessLicenseExists.value = true;
      return true;
    } catch (e) {
      Logger().e('Error fetching professional license: $e');
      isBusinessLicenseExists.value = false;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /////////////////////////
  RxList<String> licenseTypes = <String>[].obs;
  RxList<String> states = <String>[].obs;
  RxString selectedLicenseType = ''.obs;
  RxString selectedState = ''.obs;
  RxString selectedLicenseTypeId = ''.obs;

  // Inputs
  final licenseNumberController = TextEditingController();

  /// Fetches licenses and stores them as a list of maps with 'id' and 'name'.
  /// The UI should display the name but use the id as the selected value.
  RxList<Map<String, String>> licenseTypeOptions = <Map<String, String>>[].obs;

  Future<void> fetchLicenses() async {
    try {
      final response = await supabase.from('licenses').select('id,name');
      if (response.isEmpty) {
        throw Exception('No licenses found.');
      }

      // Full map with id and name
      licenseTypeOptions.value = List<Map<String, String>>.from(
        response.map<Map<String, String>>(
          (item) => {
            'id': item['id'].toString(),
            'name': item['name'].toString(),
          },
        ),
      );

      // Extract just the names for the dropdown
      licenseTypes.value = licenseTypeOptions
          .map((item) => item['name']!)
          .toList();
    } catch (e) {
      Logger().e('Failed to fetch licenses: $e');
    }
  }

  Future<void> fetchStates() async {
    try {
      final response = await supabase.from('state').select('id');
      if (response.isEmpty) {
        throw Exception('No states found.');
      }

      states.value = List<String>.from(
        response.map((item) => item['id'] as String),
      );
    } catch (e) {
      Logger().e('Failed to fetch states: $e');
    }
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
          await uploadFile(videoFile, isVideo: true);
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
            await uploadFile(imageFile, isVideo: false);
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

  final RxList<String> userImageUrls = <String>[].obs;
  final RxList<String> featureProjectImageUrls = <String>[].obs;

  // Future<void> _uploadImage(File imageFile) async {
  //   String? fileName;
  //   try {
  //     isLoading.value = true;

  //     // Get provider_id first
  //     final providerResponse = await supabase
  //         .from('service_providers')
  //         .select('provider_id')
  //         .eq('user_id', authService.userId)
  //         .single();

  //     final providerId = providerResponse['provider_id'];
  //     if (providerId == null) {
  //       throw Exception('Provider ID not found');
  //     }

  //     final userId = authService.userId;
  //     fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

  //     // This is the key: store under private/userId/fileName
  //     final filePath = 'private/$userId/$fileName';

  //     // Upload the image to Supabase Storage
  //     await supabase.storage
  //         .from('provider-project-files')
  //         .upload(filePath, imageFile);

  //     // Save file reference in database
  //     await supabase.from('provider_project_files').insert({
  //       'name': fileName,
  //       'provider_id': providerId,
  //       'caption': 'Project photo', // Optional
  //       'file_path': filePath, // You might want to save the full path
  //     });

  //     CustomFlutterToast.showSuccessToast('Image uploaded successfully');
  //     await fetchUserImages();
  //   } catch (e) {
  //     Logger().e('Error uploading image: $e');
  //     CustomFlutterToast.showErrorToast('Failed to upload image');

  //     // Cleanup: Try removing uploaded image if failed
  //     if (fileName != null) {
  //       try {
  //         final userId = authService.userId;
  //         final filePath = 'private/$userId/$fileName';
  //         await supabase.storage.from('provider-project-files').remove([
  //           filePath,
  //         ]);
  //       } catch (_) {
  //         // Ignore cleanup errors
  //       }
  //     }
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  Future<void> uploadFile(
    File file, {
    required bool isVideo,
    int? featuredProjectId,
    bool fromFeaturedProjectSection = false,
  }) async {
    String? fileName;
    try {
      isLoading.value = true;

      final providerResponse = await supabase
          .from('service_providers')
          .select('provider_id')
          .eq('user_id', authService.userId)
          .single();
      final providerId = providerResponse['provider_id'];
      if (providerId == null) throw Exception('Provider ID not found');

      final userId = authService.userId;
      final extension = path.extension(file.path);
      fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';
      final filePath = 'private/$userId/$fileName';

      // Upload file to storage
      await supabase.storage
          .from('provider-project-files')
          .upload(filePath, file);

      // Insert into DB with featured_project_id logic
      await supabase.from('provider_project_files').insert({
        'name': fileName,
        'provider_id': providerId,
        'caption': '',
        'file_path': filePath,
        'type': isVideo ? 'video' : 'image',
        'featured_project_id': fromFeaturedProjectSection
            ? (featuredProjectId ?? 0)
            : null,
      });

      await fetchUserImages(); // Refresh UI
    } catch (e) {
      Logger().e('Error uploading file: $e');
      CustomFlutterToast.showErrorToast('Failed to upload file');
      // Cleanup
      if (fileName != null) {
        final userId = authService.userId;
        final filePath = 'private/$userId/$fileName';
        try {
          await supabase.storage.from('provider-project-files').remove([
            filePath,
          ]);
        } catch (_) {}
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUserImages() async {
    try {
      isLoading.value = true;
      final user = authService.userId; // Assuming userId == provider_id
      // Get provider_id
      final providerResponse = await supabase
          .from('service_providers')
          .select('provider_id')
          .eq('user_id', user)
          .single();

      final providerId = providerResponse['provider_id'];

      // Step 1: Query table where featured_project_id is null
      final response = await supabase
          .from('provider_project_files')
          .select('file_path, name')
          .eq('provider_id', providerId)
          .filter('featured_project_id', 'is', null);

      if (response.isEmpty) {
        userImageUrls.clear();
        return;
      }

      // Step 2: Generate signed URLs for each file
      final urls = await Future.wait(
        response.map((file) async {
          final filePath = file['file_path'] as String;
          final signedUrl = await supabase.storage
              .from('provider-project-files')
              .createSignedUrl(filePath, 60 * 60);
          return signedUrl;
        }),
      );

      userImageUrls.assignAll(urls);

      // Step 3: Optionally fetch captions
      await fetchImageCaptions();
    } catch (e) {
      Logger().e('Error fetching user images: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Map to store image captions with image index as key
  final RxMap<int, String> _imageCaptions = <int, String>{}.obs;
  Map<int, String> get imageCaptions => _imageCaptions;

  // Method to update image caption
  Future<void> saveImageCaption(int index, String caption) async {
    try {
      isLoading.value = true;
      final userId = authService.userId;
      final imageUrl = userImageUrls[index];
      final folderPath = 'private/$userId';

      // Get the filename from the URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final fileName = pathSegments.last;

      // Get provider_id
      final providerResponse = await supabase
          .from('service_providers')
          .select('provider_id')
          .eq('user_id', userId)
          .single();

      final providerId = providerResponse['provider_id'];

      // Update the caption in the database
      await supabase
          .from('provider_project_files')
          .update({'caption': caption})
          .eq('provider_id', providerId)
          .eq('name', fileName);

      // Update local state
      _imageCaptions[index] = caption;

      CustomFlutterToast.showSuccessToast('Caption updated successfully');
    } catch (e) {
      Logger().e('Error saving caption: $e');
      CustomFlutterToast.showErrorToast('Failed to save caption');
    } finally {
      isLoading.value = false;
    }
  }

  // Method to fetch image captions
  Future<void> fetchImageCaptions() async {
    try {
      final userId = authService.userId;

      // Get provider_id
      final providerResponse = await supabase
          .from('service_providers')
          .select('provider_id')
          .eq('user_id', userId)
          .single();

      final providerId = providerResponse['provider_id'];

      // Fetch all captions
      final response = await supabase
          .from('provider_project_files')
          .select('name, caption')
          .eq('provider_id', providerId);

      // Clear existing captions
      _imageCaptions.clear();

      // Map captions to images
      for (int i = 0; i < userImageUrls.length; i++) {
        final imageUrl = userImageUrls[i];
        final uri = Uri.parse(imageUrl);
        final fileName = uri.pathSegments.last;

        final fileData = response.firstWhere(
          (file) => file['name'] == fileName,
          orElse: () => {},
        );

        if (fileData != null && fileData['caption'] != null) {
          _imageCaptions[i] = fileData['caption'];
        }
      }

      Logger().i('Captions loaded: ${_imageCaptions}');
    } catch (e) {
      Logger().e('Error fetching captions: $e');
    }
  }

  // Method to delete image
  Future<void> deleteImage(int index) async {
    try {
      isLoading.value = true;
      final userId = authService.userId;
      final imageUrl = userImageUrls[index];

      // Get the filename from the URL
      final uri = Uri.parse(imageUrl);
      final fileName = uri.pathSegments.last;
      final filePath = 'private/$userId/$fileName';

      // Get provider_id
      final providerResponse = await supabase
          .from('service_providers')
          .select('provider_id')
          .eq('user_id', userId)
          .single();

      final providerId = providerResponse['provider_id'];

      // Delete from database first
      await supabase
          .from('provider_project_files')
          .delete()
          .eq('provider_id', providerId)
          .eq('name', fileName);

      // Then delete from storage
      await supabase.storage.from('provider-project-files').remove([filePath]);

      // Update local state
      userImageUrls.removeAt(index);
      _imageCaptions.remove(index);

      // Reindex remaining captions
      final Map<int, String> newCaptions = {};
      _imageCaptions.forEach((key, value) {
        if (key > index) {
          newCaptions[key - 1] = value;
        } else if (key < index) {
          newCaptions[key] = value;
        }
      });
      _imageCaptions.clear();
      _imageCaptions.addAll(newCaptions);

      CustomFlutterToast.showSuccessToast('Image deleted successfully');
    } catch (e) {
      Logger().e('Error deleting image: $e');
      CustomFlutterToast.showErrorToast('Failed to delete image');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchServices() async {
    try {
      isLoading.value = true;
      final response = await supabase
          .from('services')
          .select('id, name')
          .order('name');

      if (response != null) {
        services.value = List<Map<String, dynamic>>.from(response);
      }
    } catch (e) {
      Logger().e('Error fetching services: $e');
      CustomFlutterToast.showErrorToast('Failed to fetch services');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchCities(String query) async {
    if (query.isEmpty) {
      citySearchResults.clear();
      return;
    }

    try {
      isCitySearching.value = true;
      final response = await supabase
          .from('cities')
          .select('id, city, state_id')
          .ilike('city', '%$query%')
          .limit(5);

      if (response != null) {
        citySearchResults.value = List<Map<String, dynamic>>.from(response);
      }
    } catch (e) {
      Logger().e('Error searching cities: $e');
    } finally {
      isCitySearching.value = false;
    }
  }

  Future<void> saveFeaturedProjectAndFiles({
    required List<XFile> selectedFiles,
    required String projectTitle,
    required String serviceId,
    required String cityId,
  }) async {
    try {
      isLoading.value = true;

      final userId = authService.userId;

      // Get provider_id
      final providerData = await supabase
          .from('service_providers')
          .select('provider_id')
          .eq('user_id', userId)
          .maybeSingle();

      final providerId = providerData?['provider_id'];
      if (providerId == null) throw Exception('No provider ID found for user.');

      // Insert featured project
      final featuredProjectResponse =
          await supabase.from('featured_projects').insert({
            'service_id': int.tryParse(serviceId),
            'cities_id': int.tryParse(cityId),
            'project_title': projectTitle,
            'service_provider_id': providerId,
          }).select();

      final int featuredProjectId = featuredProjectResponse[0]['id'];

      // Upload each file
      for (final file in selectedFiles) {
        final extension = path.extension(file.path);
        final fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';
        final filePath = 'private/$userId/$fileName';
        final fileToUpload = File(file.path);

        // Detect file type
        final isVideo =
            extension.toLowerCase() == '.mp4' ||
            extension.toLowerCase() == '.mov' ||
            extension.toLowerCase() == '.avi';

        try {
          // Upload to Supabase storage
          await supabase.storage
              .from('provider-project-files')
              .upload(filePath, fileToUpload);
        } catch (e) {
          throw Exception('Failed to upload file: $fileName — $e');
        }

        // Insert metadata into DB
        final insertResult = await supabase
            .from('provider_project_files')
            .insert({
              'provider_id': providerId,
              'featured_project_id': featuredProjectId,
              'name': fileName,
              'file_path': filePath,
              'type': isVideo ? 'video' : 'image',
              'created_at': DateTime.now().toIso8601String(),
            });
      }

      CustomFlutterToast.showSuccessToast(
        'Project and files saved successfully',
      );
      Get.offAndToNamed(Routes.profile);
    } catch (e) {
      Logger().e('Error saving featured project and files: $e');
      CustomFlutterToast.showErrorToast('Failed to save project and files');
    } finally {
      isLoading.value = false;
    }
  }

  // Add projectTitleController
  final projectTitleController = TextEditingController();
  final RxString selectedCityId = ''.obs;

  RxList<Map<String, dynamic>> featuredProjects = <Map<String, dynamic>>[].obs;

  Future<bool> fetchFeaturedProjects() async {
    try {
      isLoading.value = true;

      final userId = authService.userId;

      // Get provider_id
      final providerData = await supabase
          .from('service_providers')
          .select('provider_id')
          .eq('user_id', userId)
          .maybeSingle();

      final providerId = providerData?['provider_id'];
      if (providerId == null) throw Exception('No provider ID found for user.');

      // Fetch featured projects
      final response = await supabase
          .from('featured_projects')
          .select('id, project_title, service_id, cities_id')
          .eq('service_provider_id', providerId);

      if (response != null) {
        featuredProjects.value = List<Map<String, dynamic>>.from(response);
      }
      return true;
    } catch (e) {
      Logger().e('Error fetching featured projects: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
