import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/routes/routes.dart';
import '../../../core/utils/app_constants.dart';
import '../../auth/services/auth_service.dart';

class SplashController extends GetxController {
  late final SharedPreferences _prefs;
  late final AuthService _authService;
  final isInitialized = false.obs; // Changed to public for the view

  @override
  void onInit() {
    super.onInit();
    _prefs = Get.find<SharedPreferences>();
    _authService = Get.put(AuthService());
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      debugPrint('Splash: Starting initialization');

      // Minimum splash duration (2 seconds) while we load everything
      await Future.delayed(const Duration(seconds: 2));
      _authService.initializeAuthState();

      // Check onboarding status
      final hasCompletedOnboarding =
          _prefs.getBool(AppConstants.onboardingCompleteKey) ?? false;
      debugPrint('Splash: Onboarding completed: $hasCompletedOnboarding');

      if (!hasCompletedOnboarding) {
        debugPrint('Splash: Navigating to onboarding');
        await Get.offAllNamed(Routes.onboarding);
        return;
      }

      // Determine next route based on auth state
      final nextRoute = _authService.isAuthenticated.value ==true
          ? Routes.jobs
          : Routes.initial;

      debugPrint('Splash: Navigating to $nextRoute');
      await Get.offAllNamed(nextRoute);

    } catch (e, stackTrace) {
      debugPrint('Splash: Initialization error: $e');
      debugPrint('Stack trace: $stackTrace');
      await Get.offAllNamed(Routes.initial);
      Get.snackbar('Error', 'Failed to initialize app');
    } finally {
      isInitialized.value = true;
    }
  }
}