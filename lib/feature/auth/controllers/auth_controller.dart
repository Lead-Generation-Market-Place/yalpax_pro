import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/web.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yalpax_pro/core/components/question_component.dart';
import '../../../core/routes/routes.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final _authService = Get.find<AuthService>();
  
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
  bool get isAuthenticated => _authService.isAuthenticated.value;
  var isLoading = false.obs;
  User? get currentUser => _authService.currentUser.value;
  String? get authError => _authService.authError.value;

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
      if (currentUser != null) {
        email.value = currentUser!.email ?? '';

        // Get user profile from database
        final userProfile = await supabase
            .from('users_profiles')
            .select('profile_picture_url,username')
            .eq('email', currentUser!.email ?? '')
            .single();

        if (userProfile != null) {
          profilePictureUrl.value = userProfile['profile_picture_url'];
          name.value = userProfile['username'];
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  // Login Methods
  Future<void> login() async {
    try {
      final success = await _authService.signIn(
        emailController.text,
        passwordController.text,
      );

      if (success) {
        await loadUserData();
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
      final success = await _authService.signUp(
        emailController.text,
        passwordController.text,
        metadata: {'username': nameController.text},
      );

      if (success) {
        await _authService.signOut(); // Sign out after successful signup
        emailController.clear();
        passwordController.clear();
        nameController.clear();
        confirmPasswordController.clear();
        Get.toNamed(Routes.login);
      } else {
        Fluttertoast.showToast(msg: 'Failed to sign up. Please try again.');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to sign up. Please try again.');
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    Get.offAllNamed(Routes.login);
  }

  Future<void> resetPassword(String email) async {
    try {
      final success = await _authService.resetPassword(email);
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
      final success = await _authService.updatePassword(newPassword);
      if (success) {
        Fluttertoast.showToast(msg: 'Password updated successfully');
      } else {
        Fluttertoast.showToast(msg: 'Failed to update password');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to update password');
    }
  }

  // Social Auth Methods
  Future<void> signInWithGoogle() async {
    try {
      await _authService.signOut();

      const webClientId = '117669178530-m7i284g3857t4f3ol9e2vo7j9v38h0af.apps.googleusercontent.com';
      const iosClientId = '117669178530-b37fu5du424kf8q4gmjnee5c5stqnd1q.apps.googleusercontent.com';

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: iosClientId,
        serverClientId: webClientId,
        forceCodeForRefreshToken: true,
        signInOption: SignInOption.standard,
      );

      await googleSignIn.signOut();
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw 'Failed to get Google auth tokens';
      }

      Get.offAllNamed(Routes.jobs);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to sign in with Google. Please try again.',
      );
    }
  }

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
  final RxList<Map<String, dynamic>> filteredServices =
      <Map<String, dynamic>>[].obs; // Changed to Map<String, dynamic>
  final RxBool showClearButton = false.obs;

  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void onInit() async {
    super.onInit();
    // Initial fetch of popular services or all services if search is empty

  
    searchController.addListener(_onSearchChanged);
  }

  Future<void> fetchServices(String query) async {
    isLoading.value = true;
    try {
      if (query.isEmpty) {
        // Fetch initial popular services or all services when search is empty
        final response = await supabase
            .from('services')
            .select('id, name')
            .order('name', ascending: true)
            .limit(20); // Fetch ID as well
        allServices.assignAll(
          List<Map<String, dynamic>>.from(response),
        ); // Assign as List<Map<String, dynamic>>
        filteredServices.assignAll(allServices);
      } else {
        // Real-time search from Supabase
        final response = await supabase
            .from('services')
            .select('id, name')
            .ilike('name', '%' + query + '%')
            .order('name', ascending: true); // Fetch ID as well
        filteredServices.assignAll(
          List<Map<String, dynamic>>.from(response),
        ); // Assign as List<Map<String, dynamic>>
      }
    } catch (e) {
      print('Error fetching services: $e');
      // Optionally, show a Get.snackbar or other UI feedback
    } finally {
      isLoading.value = false;
    }
  }

  void _onSearchChanged() {
    fetchServices(searchController.text);
    showClearButton.value = searchController.text.isNotEmpty;
  }

  void filterServices(String query) {
    // This method is now redundant as _fetchServices handles filtering from Supabase
    // Keeping it for now to avoid breaking existing calls, but its logic is moved
  }

  void clearSearch() {
    searchController.clear();
    fetchServices(''); // Fetch all services again
    showClearButton.value = false;
  }

  RxList<Map<String, dynamic>> services = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> questions = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> answers = <Map<String, dynamic>>[].obs;



  void handleQuestionFlowAnswers(Map<String, dynamic> selectedAnswers) {
    answers.value = selectedAnswers.entries.map((entry) {
      return {
        'question_id': entry.key,
        'answer_id': entry.value is Set ? entry.value.toList() : [entry.value],
      };
    }).toList();
  }

  Future<void> fetchQuestions(int serviceId) async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final response = await supabase
          .from('questions')
          .select('''
          *,
          question_answers!inner(
            answers!inner(*)
          )
        ''')
          .eq('service_id', serviceId)
          .order('id');

      if (response != null) {
        questions.value = List<Map<String, dynamic>>.from(response);
        final parsedQuestions = parseQuestions(questions);

        if (parsedQuestions.isEmpty) {
          Get.snackbar(
            'No Questions Found',
            'There are no questions for this service.',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          final result = await Get.to(
            () => QuestionFlowScreen(questions: parsedQuestions),
          );
          Logger().d('Answers of questions :-  $result');
          Fluttertoast.showToast(msg: '$result');
          if (result != null) {
            handleQuestionFlowAnswers(result);
          }
        }
      }
    } catch (e) {
      print('Error fetching questions: $e');
      Get.snackbar(
        'Error',
        'Failed to load questions. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<Question> parseQuestions(List<Map<String, dynamic>> rawQuestions) {
    return rawQuestions.map((q) {
      final String typeStr = (q['type'] ?? '').toString().toLowerCase();
      final QuestionType type = typeStr == 'checkbox'
          ? QuestionType.multipleChoice
          : QuestionType.singleChoice;

      final options = (q['question_answers'] as List).map((qa) {
        final ans = qa['answers'];
        return QuestionOption(
          id: ans['id'].toString(),
          label: ans['text'] ?? '',
          value: ans['id'],
        );
      }).toList();

      return Question(
        id: q['id'].toString(),
        question: q['text'] ?? '',
        type: type,
        options: options,
        isRequired: true,
      );
    }).toList();
  }

  //////////////////////////////
  var selectedServices = <int>{}.obs;
  var selectedService = {}.obs; // from FirstStep

void toggleService(int serviceId) {
  if (selectedServices.contains(serviceId)) {
    selectedServices.clear();
  } else {
    selectedServices.clear();
    selectedServices.add(serviceId);
  }
}

  Future<void> _fetchRelatedServices(int serviceId) async {
    isLoading.value = true;
    try {
      // First get the category_id of the selected service
      final selectedService = await supabase
          .from('services')
          .select('''
            id,
            sub_categories!inner(
              id,
              category_id
            )
          ''')
          .eq('id', serviceId)
          .single();

      if (selectedService != null) {
        final categoryId = selectedService['sub_categories']['category_id'];
        
        // Now fetch all services that belong to the same category
        final response = await supabase
            .from('services')
            .select('''
              id,
              name,
              description,
              service_image_url,
              sub_categories!inner(
                id,
                category_id
              )
            ''')
            .neq('id', serviceId) // Exclude the selected service
            .eq('sub_categories.category_id', categoryId)
            .order('name', ascending: true)
            .limit(20);

        if (response != null) {
          filteredServices.assignAll(List<Map<String, dynamic>>.from(response));
        }
      }
    } catch (e) {
      print('Error fetching related services: $e');
    } finally {
      isLoading.value = false;
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

  ////////////////////////////////
  var fullName = 'Feroz Durrani'.obs;
  var email1 = 'durraniferoz9@gmail.com'.obs;
  var phoneController = TextEditingController();
  var enableTextMessages = true.obs;

  void registerUser() {
    final phone = phoneController.text;
    final smsEnabled = enableTextMessages.value;
    print("Phone: $phone, SMS enabled: $smsEnabled");
    // Continue to next step or API
  }
}
