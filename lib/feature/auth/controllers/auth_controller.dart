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
import 'package:yalpax_pro/core/widgets/custom_flutter_toast.dart';
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
  RxString googleAccountPictureUrl = ''.obs;

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
    super.onClose();
  }

  Future<void> loadUserData() async {
    try {
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
        final identities = currentUser!.identities;

        if (identities != null && identities.isNotEmpty) {
          final googleIdentity = identities.firstWhereOrNull(
            (identity) => identity.provider == 'google',
          );

          if (googleIdentity != null) {
            final avatarUrl = googleIdentity.identityData?['avatar_url'] ?? '';
            googleAccountPictureUrl.value = avatarUrl;
            print(googleAccountPictureUrl.value);
          }
        }

        profilePictureUrl.value = userProfile['profile_picture_url'] ?? '';
        name.value = userProfile['username'] ?? '';
      } else {
        debugPrint('No user profile found in the database.');
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  // Login Methods
  Future<void> handlePostLogin({User? user, String? usernameFromOAuth}) async {
    try {
      user ??= supabase.auth.currentUser;
      if (user == null) {
        Fluttertoast.showToast(msg: 'User data is missing.');
        return;
      }

      final email = user.email;
      final username = usernameFromOAuth ?? user.userMetadata?['username'];

      if (email == null) {
        Fluttertoast.showToast(msg: 'Email not available.');
        return;
      }

      if (username == null || username.trim().isEmpty) {
        Fluttertoast.showToast(msg: 'Username missing.');
        return;
      }

      final existingUser = await supabase
          .from('users_profiles')
          .select()
          .eq('email', email)
          .maybeSingle();

      final proServiceResponse = await supabase
          .from('pro_services')
          .select()
          .eq('user_id', user.id);

      if (proServiceResponse.isEmpty && selectedServices.isEmpty) {
        Fluttertoast.showToast(msg: 'Please select the services you offer.');

        Get.toNamed(Routes.initial);
        return;
      } else if (proServiceResponse.isEmpty && selectedServices.isNotEmpty) {
        await proSignUpProces();
      }

      if (existingUser == null) {
        final usernameExists = await supabase
            .from('users_profiles')
            .select()
            .eq('username', username)
            .maybeSingle();

        var finalUsername = username;

        if (usernameExists != null) {
          final random = DateTime.now().millisecondsSinceEpoch % 10000;
          finalUsername = '${username}_$random';
        }

        await supabase.from('users_profiles').insert({
          'id': user.id,
          'email': email,
          'username': finalUsername,
        });
      }

      final serviceProvider = await supabase
          .from('service_providers')
          .select('business_name')
          .eq('user_id', user.id)
          .maybeSingle();

      if (existingUser != null && existingUser['phone_number'] == null) {
        Get.toNamed(Routes.thirdStep);
      } else if (serviceProvider == null) {
        Get.toNamed(Routes.fourthStep);
      } else if (serviceProvider.isNotEmpty) {
        Get.toNamed(Routes.jobs);
        authService.isAuthenticated.value = true;
        authService.currentUser.value = user;
      } else {
        await proSignUpProces();
        Get.toNamed(Routes.thirdStep);
      }

      emailController.clear();
      passwordController.clear();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Post-login error: $e');
    }
  }

  Future<void> Login() async {
    try {
      isLoading.value = true;

      // Sign in with Supabase
      final response = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Check if user exists in auth
      if (response.user == null) {
        Fluttertoast.showToast(msg: 'Authentication failed. Please try again.');
        return;
      }

      final user = response.user;
      final authUserId = user!.id;
      print('authUserId: $authUserId');
      final email = user?.email ?? '';
      final username = user?.userMetadata?['username']?.toString();

      // Check user profile in database
      final existingUser = await supabase
          .from('users_profiles')
          .select()
          .eq('email', email)
          .maybeSingle();

      // Handle new users
      if (existingUser == null) {
        if (username == null || username.trim().isEmpty) {
          CustomFlutterToast.showInfoToast('Username is required.', seconds: 2);
          return;
        }

        // Check for username uniqueness
        final usernameExists = await supabase
            .from('users_profiles')
            .select()
            .eq('username', username)
            .maybeSingle();

        var finalUsername = username;
        if (usernameExists != null) {
          final random = DateTime.now().millisecondsSinceEpoch % 10000;
          finalUsername = '${username}_$random';
        }

        // Create new user profile
        await supabase.from('users_profiles').insert({
          'id': authUserId,
          'email': email,
          'username': finalUsername,
        });
      }

      // Check for service provider status
      final proServiceResponse = await supabase
          .from('pro_services')
          .select()
          .eq('user_id', authUserId);

      // Handle service provider flow
      if (proServiceResponse.isEmpty && selectedServices.isEmpty) {
        CustomFlutterToast.showInfoToast(
          'Please select the services you offer.',
          seconds: 5,
        );

        Get.toNamed(Routes.firstStep);
        return;
      } else if (proServiceResponse.isEmpty && selectedServices.isNotEmpty) {
        await proSignUpProces();
      }

      // Check service provider profile
      final serviceProvider = await supabase
          .from('service_providers')
          .select('business_name')
          .eq('user_id', user.id)
          .maybeSingle();

      // Determine next steps based on user state
      if (existingUser!['phone_number'] == null ||
          existingUser['phone_number'] == '') {
        Get.toNamed(Routes.thirdStep);
      } else {
        authService.isAuthenticated.value = true;
        authService.currentUser.value = user;
        Get.toNamed(Routes.jobs);
      }

      // Clear input fields
      emailController.clear();
      passwordController.clear();
    } on AuthException catch (e) {
      Fluttertoast.showToast(msg: 'Login failed: ${e.message}');
    } catch (e) {
      Fluttertoast.showToast(msg: 'An error occurred: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp() async {
    isLoading.value = true;
    try {
      final success = await supabase.auth.signUp(
        email: emailController.text,
        password: passwordController.text,
        data: {'username': nameController.text},
      );

      if (success.user != null) {
        await authService.signOut(); // Sign out after successful signup
        nameController.clear();
        emailController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
        acceptedTerms.value = false;

        Get.toNamed(Routes.login);

        CustomFlutterToast.showInfoToast(
          'Please confirm you email, before login.',
          seconds: 5,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to sign up. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await authService.signOut();
    authService.isAuthenticated.value = false;
    authService.currentUser.value = null;

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

  var forceUpdate = false.obs;
  void toggleForceUpdate() {
    forceUpdate.value = !forceUpdate.value;
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

  final TextEditingController yearFoundedController = TextEditingController();
  final TextEditingController numberOfEmployeesController =
      TextEditingController();
  final TextEditingController streetNameController = TextEditingController();
  final TextEditingController suiteOrUniteController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  final TextEditingController businessDetailsInfo = TextEditingController();

  var bottomSheetShown = false.obs;

  //////////////////////////////
  final TextEditingController phoneController = TextEditingController();
  var enableTextMessages = true.obs;

  Future<void> registerUser() async {
    final authUser = authService.currentUser.value!.id;

    isLoading.value = true;
    try {
      if (selectedState.value != null &&
          phoneController.text.isNotEmpty &&
          selectedImageFile.value != null &&
          businessNameController.text.isNotEmpty &&
          businessDetailsInfo.text.isNotEmpty) {
        String? profileImageFileName;
        if (selectedImageFile.value != null) {
          await updateProfileImage(selectedImageFile.value!);
          profileImageFileName = profilePictureUrl.value;
        }
        final userPhoneNumberResponse = await supabase
            .from('users_profiles')
            .update({
              'phone_number': phoneController.text,
              'profile_picture_url': profileImageFileName,
            })
            .eq('id', authUser);

        if (userPhoneNumberResponse != null) {
          Fluttertoast.showToast(
            msg: 'You phone number have been added successfully.',
          );
        }

        /////////////////////////////////////////////////////////

        final businessName = businessNameController.text.trim();

        // Step 2: Build the data map for insertion
        final insertData = {
          'user_id': authUser,
          'founded_year': int.tryParse(yearFoundedController.text),
          'employees_count': int.tryParse(numberOfEmployeesController.text),
          'business_name': businessName,
          'business_type':
              'company', // Make sure it's set (e.g., 'handyman' or 'company')
          'introduction': businessDetailsInfo.text.trim(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        // Step 3: Insert into service_providers
        final result = await supabase
            .from('service_providers')
            .insert(insertData)
            .eq('user_id', authUser)
            .select('provider_id');

        if (result == null || result[0]['provider_id'] == null) {
          throw 'Failed to create service provider';
        }

        final locationResponse = await supabase
            .from('locations')
            .insert({
              'address_line1': streetNameController.text,
              'address_line2': suiteOrUniteController.text,
              'city': cityController.text,
              'state': selectedState.value!['name'],
              'zip': zipCodeController.text,
              'timezone': null,
            })
            .select('id');

        if (locationResponse.isNotEmpty) {
          await supabase.from('provider_locations').insert({
            'state_id': locationResponse[0]['id'],
            'provider_id': result[0]['provider_id'],
            'is_primary': true,
          });
        }
      }

      authService.isAuthenticated.value = true;
      Get.toNamed(Routes.tenthStep);
    } catch (e) {
      print(e); // Continue to next step or API
    } finally {
      isLoading.value = false;
    }
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
      final fileName =
          '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
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
      loadUserData();
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

  Rx<File?> selectedImageFile = Rx<File?>(null);

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
                      // updateProfileImage(file);
                      // Logger().d(file);

                      selectedImageFile.value = file; // set local file
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
                      // updateProfileImage(file);
                      selectedImageFile.value = file;

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

  /////////////////////////////////////////////////////////////////////////////////////
  // professional Signup

  Future<void> proSignUpProces() async {
    try {
      isLoading.value = true;

      final authUser = authService.currentUser.value;
      if (authUser == null) throw 'User not authenticated';

      final userEmail = authUser.email;
      if (userEmail == null) throw 'User email not found';

      // Step 1: Get current user's profile by email
      final userProfile = await supabase
          .from('users_profiles')
          .select('id, phone_number')
          .eq('email', userEmail)
          .maybeSingle();

      if (userProfile == null || userProfile['id'] == null) {
        throw 'User profile not found';
      }

      final profileId = userProfile['id'];
      final phoneNumber = userProfile['phone_number'];

      // Step 2: Insert selected services
      final List<Map<String, dynamic>> rowsToInsert = selectedServices.map((
        serviceId,
      ) {
        return {'user_id': profileId, 'service_id': int.tryParse(serviceId)};
      }).toList();

      if (rowsToInsert.isNotEmpty) {
        await supabase.from('pro_services').insert(rowsToInsert);
      }

      // Step 3: Navigate based on phone number presence
      if (phoneNumber == null || phoneNumber.isEmpty) {
        Get.toNamed(Routes.thirdStep);
      }
    } catch (e) {
      Logger().e('Error in proSignUpProces: $e');
      Get.snackbar(
        'Error',
        'Failed to process professional signup',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Future<void> addBusinessName() async {
  //   try {
  //     isLoading.value = true;

  //     final businessName = businessNameController.text.trim();
  //     final authUser = authService.currentUser.value;

  //     if (authUser == null || businessName.isEmpty) {
  //       print('User not logged in or business name empty.');
  //       return;
  //     }

  //     final existingProvider = await supabase
  //         .from('service_providers')
  //         .select()
  //         .eq('user_id', authUser.id)
  //         .maybeSingle(); // Only get one row if exists

  //     if (existingProvider != null) {
  //       // Update existing row
  //       await supabase
  //           .from('service_providers')
  //           .update({'business_name': businessName})
  //           .eq('user_id', authUser.id);
  //     } else {
  //       // Insert new row
  //       await supabase.from('service_providers').insert({
  //         'user_id': authUser.id,
  //         'business_name': businessName,
  //       });
  //     }
  //     authService.isAuthenticated.value = true;
  //     Get.toNamed(Routes.sixthstep);
  //   } catch (e) {
  //     print('Error adding business name: $e');
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  final RxList<Map<String, dynamic>> allStates = <Map<String, dynamic>>[].obs;
  final Rx<Map<String, dynamic>?> selectedState = Rx<Map<String, dynamic>?>(
    null,
  );

  Future<void> fetchStates(String query) async {
    isLoading.value = true;
    try {
      final response = await supabase
          .from('state')
          .select('id, name, code') // columns in the `state` table
          .ilike('name', '%$query%')
          .order('name', ascending: true)
          .limit(20);

      Logger().d(response);

      allStates.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      print('Error fetching states from state table: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> serviceProviderLocation(String authUserId) async {
    try {
      isLoading.value = true;
      Logger().d(selectedState);

      // ✅ Step 1: Ensure the provider exists in service_providers
      final providerExists = await supabase
          .from('service_providers')
          .select()
          .eq('user_id', authUserId)
          .select();

      if (providerExists.isEmpty) {
        Logger().d('provider already exists.');
      }
      final insertResponse = await supabase
          .from('szw')
          .insert({
            'user_id': authUserId,
            'business_name': '',
            'created_at': DateTime.now().toIso8601String(),
          })
          .select('provider_id');

      // ✅ Step 2: Check if location already exists
      final existing = await supabase
          .from('provider_locations')
          .select()
          .eq('provider_id', insertResponse[0]['provider_id']);

      final payload = {
        'state_id': selectedState.value!['id'],
        'is_primary': true,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (existing.isNotEmpty) {
        await supabase
            .from('provider_locations')
            .update(payload)
            .eq('provider_id', insertResponse[0]['provider_id']);
      } else {
        payload['created_at'] = DateTime.now().toIso8601String();
        await supabase.from('provider_locations').insert(payload);
      }
      Get.toNamed(Routes.fourthStep);
    } catch (e) {
      print('Error updating provider_locations: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Future<void> fetchBusinessLocation() async {
  //   try {
  //     final authUserId = supabase.auth.currentUser!.id;

  //     // Step 1: Get provider_id linked to the authenticated user
  //     final providerResponse = await supabase
  //         .from('service_providers')
  //         .select('provider_id')
  //         .eq('user_id', authUserId)
  //         .maybeSingle();

  //     if (providerResponse == null) {
  //       print('No service provider found for this user.');
  //       return;
  //     }

  //     final providerId = providerResponse['provider_id'];

  //     // Step 2: Get the provider's primary state_id and join it with the state table
  //     final locationResponse = await supabase
  //         .from('provider_locations')
  //         .select('id, is_primary, state_id, state:id(name, code)')
  //         .eq('provider_id', providerId)
  //         .eq('is_primary', true)
  //         .maybeSingle();

  //     print('Fetched provider location: $locationResponse');

  //     if (locationResponse == null || locationResponse['state'] == null) {
  //       print('Primary state not set or state not found.');
  //       return;
  //     }

  //     final state = locationResponse['state'];
  //     final selected = {
  //       'id': locationResponse['state_id'],
  //       'name': state['name'],
  //       'code': state['code'],
  //     };

  //     // Step 3: Set it to controller
  //     selectedState.value = selected;

  //     // Add it to dropdown if not already present
  //     final exists = allStates.any((s) => s['id'] == selected['id']);
  //     if (!exists) {
  //       allStates.add(selected);
  //     }
  //   } catch (e) {
  //     print('Error fetching primary state: $e');
  //   }
  // }

  // final TextEditingController yearFoundedController = TextEditingController();
  // final TextEditingController numberOfEmployeesController =
  //     TextEditingController();
  // final TextEditingController streetNameController = TextEditingController();
  // final TextEditingController suiteOrUniteController = TextEditingController();
  // final TextEditingController cityController = TextEditingController();
  // final TextEditingController zipCodeController = TextEditingController();
  // final TextEditingController businessDetailsInfo = TextEditingController();

  // var bottomSheetShown = false.obs;

  // Future<void> saveBusinessUserInfo() async {
  //   try {
  //     isLoading.value = true;

  //     final authUser = authService.currentUser.value!.id;

  //     // Step 2: Build the data map for insertion
  //     final insertData = {
  //       'user_id': authUser,
  //       'founded_year': int.tryParse(yearFoundedController.text),
  //       'employees_count': int.tryParse(numberOfEmployeesController.text),
  //       'business_type':
  //           'company', // Make sure it's set (e.g., 'handyman' or 'company')
  //       'introduction': businessDetailsInfo.text.trim(),
  //       'created_at': DateTime.now().toUtc(),
  //       'updated_at': DateTime.now().toUtc(),
  //     };

  //     // Step 3: Insert into service_providers
  //     final result = await supabase
  //         .from('service_providers')
  //         .update(insertData)
  //         .eq('user_id', authUser);

  //     if (result == null || result['provider_id'] == null) {
  //       throw 'Failed to create service provider';
  //     }

  //     final providerId = result['provider_id'];

  //     // Optional Step 4: Save primary location if you already have a selectedState
  //     if (selectedState.value != null) {
  //       await supabase
  //           .from('provider_locations')
  //           .update({
  //             'state_id': selectedState.value!['id'],

  //             'updated_at': DateTime.now().toUtc(),
  //           })
  //           .eq('provider_id', providerId);
  //     }

  //     CustomFlutterToast.showSuccessToast(
  //       'Business Profile saved successfully.',
  //     );
  //   } catch (e) {
  //     print('Error adding business info into database: $e');
  //     Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
}
