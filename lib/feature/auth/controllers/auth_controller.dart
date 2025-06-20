import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yalpax_pro/core/widgets/image_picker.dart';
import '../../../core/routes/routes.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final authService = Get.find<AuthService>();

  // Text Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Observable variables
  final acceptedTerms = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;
  final emailError = RxnString();
  final passwordError = RxnString();
  final nameError = RxnString();
  final confirmPasswordError = RxnString();
  final termsError = RxnString();
  RxString email = ''.obs;
  RxString name = ''.obs;
  RxString profilePictureUrl = ''.obs;

  // Reset password variables
  final resetEmailError = RxnString();
  final resetTokenError = RxnString();
  final resetPasswordError = RxnString();
  final resetConfirmPasswordError = RxnString();

  // Computed properties
  bool get isAuthenticated => authService.isAuthenticated.value;
  var isLoading = false.obs;
  User? get currentUser => authService.currentUser.value;
  String? get authError => authService.authError.value;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

    
  Future<void> loadUserData() async {
  try {
    isLoading.value = true;
    if (currentUser == null) {
      debugPrint('User is not logged in.');
      return;
    }

    email.value = currentUser!.email ?? '';

    final userProfile = await supabase
        .from('users_profiles')
        .select('profile_picture_url,username,email')
        .eq('email', currentUser!.email ?? '')
        .maybeSingle(); // safer than .single()

    if (userProfile != null) {
      profilePictureUrl.value = userProfile['profile_picture_url'] ?? '';
      name.value = userProfile['username'] ?? '';
      // email.value = userProfile['email'] ?? '';
    } else {
      debugPrint('No user profile found in the database.');
    }

  } catch (e) {
    debugPrint('Error loading user data: $e');
  }finally{
    isLoading.value = false;
  }
}


  // Login Methods
  Future<void> login() async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      final user = response.user;

      if (user != null) {
        final userMetadata = user.userMetadata;
        final username = userMetadata?['username']; // safely extract 'username'

        if (username != null) {
          await supabase.from('users_profiles').insert({
            'email': emailController.text,
            'username': username,
          });
        }

        Get.offAllNamed(Routes.jobs);
        emailController.clear();
        passwordController.clear();
      } else {
        Fluttertoast.showToast(msg: 'Failed to login. Please try again.');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to login. Please try again. $e');
    }
  }

  Future<void> signUp() async {
    try {
      final success = await authService.signUp(
        emailController.text,
        passwordController.text,
        metadata: {'username': nameController.text},
      );

      if (success) {
        await authService.signOut(); // Sign out after successful signup
        emailController.clear();
        passwordController.clear();
        nameController.clear();
        confirmPasswordController.clear();
        Get.toNamed(Routes.thirdStep);
      } else {
        Fluttertoast.showToast(msg: 'Failed to sign up. Please try again.');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to sign up. Please try again.');
    }
  }

  Future<void> signOut() async {
    await authService.signOut();

    Get.offAllNamed(Routes.login);
  }

  Future<void> resetPassword(String email) async {
    try {
      final success = await authService.resetPassword(email);
      if (success) {
        emailController.clear();
        Fluttertoast.showToast(msg: 'Reset email sent');
      } else {
        Fluttertoast.showToast(msg: 'Failed to send reset email');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to send reset email');
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      final success = await authService.updatePassword(newPassword);
      if (success) {
        Fluttertoast.showToast(msg: 'Password updated successfully');
      } else {
        Fluttertoast.showToast(msg: 'Failed to update password');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to update password');
    }
  }

  ///////////////////////////////////////////////////////////////////////////////

  static SupabaseClient client() {
    final supabase = Supabase.instance.client;
    return supabase;
  }

  static Future<AuthResponse> signInWithGoogle() async {
    /// TODO: update the Web client ID with your own.

    /// Web Client ID that you registered with Google Cloud.
    const webClientId =
        '700150215178-ctv5m5b45btkfn0qdhhcgagusvkk3oeu.apps.googleusercontent.com';

    /// TODO: update the iOS client ID with your own.
    ///
    /// iOS Client ID that you registered with Google Cloud.

    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: webClientId,
      forceCodeForRefreshToken: true,
      signInOption: SignInOption.standard,
    );
    await googleSignIn.signOut();
    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null) {
      throw 'No Access Token found.';
    }
    if (idToken == null) {
      throw 'No ID Token found.';
    }

    return client().auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  // // Social Auth Methods
  // Future<void> signInWithGoogle() async {
  //   try {
  //     await authService.signOut();

  //     const webClientId = '117669178530-m7i284g3857t4f3ol9e2vo7j9v38h0af.apps.googleusercontent.com';
  //     const iosClientId = '117669178530-b37fu5du424kf8q4gmjnee5c5stqnd1q.apps.googleusercontent.com';

  //     final GoogleSignIn googleSignIn = GoogleSignIn(
  //       clientId: iosClientId,
  //       serverClientId: webClientId,
  //       forceCodeForRefreshToken: true,
  //       signInOption: SignInOption.standard,
  //     );

  //     await googleSignIn.signOut();
  //     final googleUser = await googleSignIn.signIn();
  //     final googleAuth = await googleUser!.authentication;
  //     final accessToken = googleAuth.accessToken;
  //     final idToken = googleAuth.idToken;

  //     if (accessToken == null || idToken == null) {
  //       throw 'Failed to get Google auth tokens';
  //     }

  //     Get.offAllNamed(Routes.jobs);
  //   } catch (e) {
  //     Fluttertoast.showToast(
  //       msg: 'Failed to sign in with Google. Please try again.',
  //     );
  //   }
  // }

  Future<void> signInWithApple() async {
    try {
      final response = await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: kIsWeb
            ? null
            : Platform.isAndroid
            ? 'us-connector://login-callback'
            : 'us.connector://login-callback',
        authScreenLaunchMode: LaunchMode.inAppWebView,
      );

      if (!response) {
        throw 'Apple sign in failed';
      }

      Get.offAllNamed(Routes.jobs);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to sign in with Apple. Please try again.',
      );
    }
  }

  /////////////////////////////////////
  ///
  ///
  final searchController = TextEditingController();
  final zipCodeController = TextEditingController();

  final RxList<Map<String, dynamic>> allServices =
      <Map<String, dynamic>>[].obs; // Changed to Map<String, dynamic>
  final RxList<Map<String, dynamic>> allCategories =
      <Map<String, dynamic>>[].obs; // Changed to Map<String, dynamic>
  final RxList<Map<String, dynamic>> allSubCategories =
      <Map<String, dynamic>>[].obs; // Changed to Map<String, dynamic>
  final RxList<Map<String, dynamic>> filteredServices =
      <Map<String, dynamic>>[].obs; // Changed to Map<String, dynamic>
  final RxList<Map<String, dynamic>> filteredCategories =
      <Map<String, dynamic>>[].obs; // Changed to Map<String, dynamic>
  final RxList<Map<String, dynamic>> filteredSubCategories =
      <Map<String, dynamic>>[].obs; // Changed to Map<String, dynamic>
  final RxBool showClearButton = false.obs;

  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void onInit() async {
    super.onInit();
    // Initial fetch of popular services or all services if search is empty
  
    searchController.addListener(_onSearchChanged);
  }

  final RxList<Map<String, dynamic>> subCategoryServices =
      <Map<String, dynamic>>[].obs;

  Future<void> fetchServicesBySubCategory(String subCategoryId) async {
    isLoading.value = true;
    try {
      final response = await supabase
          .from('services')
          .select('id, name')
          .eq(
            'sub_categories_id',
            subCategoryId,
          ) // Assuming this relationship exists
          .order('name', ascending: true);

      subCategoryServices.assignAll(List<Map<String, dynamic>>.from(response));
      filteredServices.assignAll(subCategoryServices);
    } catch (e) {
      print('Error fetching services: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Update toggleSubCategories
  void toggleSubCategories(String subCategoryId) {
    if (selectedSubCategories.contains(subCategoryId)) {
      selectedSubCategories.remove(subCategoryId);
      subCategoryServices.clear();
      filteredServices.clear();
    } else {
      selectedSubCategories
        ..clear()
        ..add(subCategoryId);
      fetchServicesBySubCategory(subCategoryId);
    }
  }

  // Then update the services dropdown similarly to search locally
  Future<void> fetchCategories(String query) async {
    isLoading.value = true;
    try {
      if (query.isEmpty) {
        final response = await supabase
            .from('categories')
            .select('id, name')
            .order('name', ascending: true)
            .limit(20);
        allCategories.assignAll(List<Map<String, dynamic>>.from(response));
        filteredCategories.assignAll(allCategories);
      } else {
        final response = await supabase
            .from('categories') // Ensure we're querying categories table
            .select('id, name')
            .ilike('name', '%$query%')
            .order('name', ascending: true);
        filteredCategories.assignAll(
          List<Map<String, dynamic>>.from(response),
        ); // Assign to filteredCategories
      }
    } catch (e) {
      print('Error fetching categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // In AuthController
  final RxList<Map<String, dynamic>> categorySubCategories =
      <Map<String, dynamic>>[].obs;

  Future<void> fetchSubCategoriesByCategory(String categoryId) async {
    isLoading.value = true;
    try {
      final response = await supabase
          .from('sub_categories')
          .select('id, name')
          .eq(
            'category_id',
            categoryId,
          ) // Assuming you have a category_id column
          .order('name', ascending: true);

      categorySubCategories.assignAll(
        List<Map<String, dynamic>>.from(response),
      );
      filteredSubCategories.assignAll(categorySubCategories);
    } catch (e) {
      print('Error fetching subcategories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Modify the toggleCategories method to fetch subcategories
  void toggleCategories(String categoryId) {
    if (selectedCategories.contains(categoryId)) {
      selectedCategories.remove(categoryId);
      categorySubCategories.clear();
      filteredSubCategories.clear();
    } else {
      selectedCategories
        ..clear()
        ..add(categoryId);
      fetchSubCategoriesByCategory(categoryId);
    }
  }

  void _onSearchChanged() {
    // fetchServices(searchController.text);
    fetchCategories(searchController.text);
    // fetchSubCategories(searchController.text);
    showClearButton.value = searchController.text.isNotEmpty;
  }

  void clearSearch() {
    searchController.clear();
    // fetchServices(''); // Fetch all services again
    fetchCategories(''); // Fetch all categories again
    // fetchSubCategories(''); // Fetch all categories again
    showClearButton.value = false;
  }

  RxList<Map<String, dynamic>> services = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> questions = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> answers = <Map<String, dynamic>>[].obs;

  //////////////////////////////

  var selectedService = {}.obs; // from FirstStep

  // Change from Set<int> to RxList<String> to match your ID types
  final selectedServices = <String>[].obs;
  final selectedCategories = <String>[].obs;
  final selectedSubCategories = <String>[].obs;
  // void toggleCategories(String categoryId) {
  //   if (selectedCategories.contains(categoryId)) {
  //     selectedCategories.remove(categoryId);
  //   } else {
  //     selectedCategories
  //       ..clear()
  //       ..add(categoryId);
  //   }
  // }

  // void toggleSubCategories(String subCategoryId) {
  //   if (selectedSubCategories.contains(subCategoryId)) {
  //     selectedSubCategories.remove(subCategoryId);
  //   } else {
  //     selectedSubCategories
  //       ..clear()
  //       ..add(subCategoryId);
  //   }
  // }

  void toggleServices(String serviceId) {
    if (selectedServices.contains(serviceId)) {
      selectedServices.remove(serviceId);
    } else {
      selectedServices.add(serviceId);
    }
  }

  void selectAllServices() {
    for (var service in allServices) {
      if (service['id'] != selectedService['id']) {
        selectedServices.add(service['id']);
      }
    }
  }

  void submitSelectedServices() {
    // Combine selectedService + selectedServices
    final allSelected = [selectedService['id'], ...selectedServices];
    print("Selected IDs: $allSelected");
    // Save to backend or session here
  }

  //////////////////////////////////////////////////////////////////////
  ///thirdstep

  final TextEditingController phoneController = TextEditingController();
  var enableTextMessages = true.obs;

  void registerUser() {
    final phone = phoneController.text;
    final smsEnabled = enableTextMessages.value;
    print("Phone: $phone, SMS enabled: $smsEnabled");
    // Continue to next step or API
  }

  

  Future<void> showPermissionDialog(
    String title,
    String message,
    Permission permission,
  ) async {
    await Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }


    Future<bool> handlePermission(ImageSource source) async {
    final androidVersion =
        await DeviceInfoPlugin().androidInfo; //package to get Device Info

    if (source == ImageSource.camera) {
      if (Platform.isAndroid) {
        if (androidVersion.version.sdkInt <= 28) {
          final status = await Permission.camera.status;

          if (status.isPermanentlyDenied) {
            await showPermissionDialog(
              'Camera Permission Required',
              'Camera access is required to take photos. Please enable it in your device settings.',
              Permission.camera,
            );
            return false;
          }

          final result = await Permission.camera.request();
          if (result.isDenied) {
            Get.snackbar(
              'Permission Required',
              'Camera permission is required to take photos',
              snackPosition: SnackPosition.BOTTOM,
            );
            return false;
          }
        } else {
          return true; // No permission needed for Android 10+
        }
      }
    } else {
      // For gallery access
      if (Platform.isAndroid) {
        final status = await Permission.storage.status;
        if (androidVersion.version.sdkInt <= 28) {
          if (status.isPermanentlyDenied) {
            await showPermissionDialog(
              'Storage Permission Required',
              'Storage access is required to select images. Please enable it in your device settings.',
              Permission.storage,
            );
            return false;
          }

          final result = await Permission.storage.request();
          if (result.isDenied) {
            Get.snackbar(
              'Permission Required',
              'Storage permission is required to select images',
              snackPosition: SnackPosition.BOTTOM,
            );
            return false;
          }
        } else {
          return true;
          ;
        }
      } else if (Platform.isIOS) {
        // On iOS, we need photos permission
        final status = await Permission.photos.status;
        if (status.isPermanentlyDenied) {
          await showPermissionDialog(
            'Photos Permission Required',
            'Photos access is required to select images. Please enable it in your device settings.',
            Permission.photos,
          );
          return false;
        }

        final result = await Permission.photos.request();
        if (result.isDenied) {
          Get.snackbar(
            'Permission Required',
            'Photos permission is required to select images',
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        }
      }
    }

    return true;
  }


  Future<void> updateProfileImage(File imageFile) async {
    try {
      isLoading.value = true;
      
      // Get the current user's email
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Upload image to Supabase Storage
      final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final response = await supabase.storage
          .from('userprofilepicture')
          .upload(fileName, imageFile);

      // Get the public URL of the uploaded image
      final imageUrl = supabase.storage
          .from('userprofilepicture')
          .getPublicUrl(fileName);

      // Update the user's profile in the database
      await supabase
          .from('users_profiles')
          .update({'profile_picture_url': fileName})
          .eq('email', email);

      // Update the local state
      profilePictureUrl.value = fileName;
      
      Get.snackbar(
        'Success',
        'Profile picture updated successfully',
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


  

  void showImagePickerBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(context);

                  if (await handlePermission(ImageSource.camera)) {
                    final file = await ImagePickerService().pickFromCamera();
                    if (file != null) {
                      // TODO: Handle the picked image file
                      // You can upload it to your server or update the profile picture
                      updateProfileImage(file);
                      Logger().d(file);
                      Get.snackbar('Success', 'Image captured successfully');
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  if (await handlePermission(ImageSource.gallery)) {
                    final file = await ImagePickerService().pickFromGallery();
                    if (file != null) {
                      Logger().d(file);
                      // TODO: Handle the picked image file
                      // You can upload it to your server or update the profile picture
                      updateProfileImage(file);
                      Get.snackbar('Success', 'Image selected successfully');
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
  final TextEditingController businessNameController = TextEditingController();
}
