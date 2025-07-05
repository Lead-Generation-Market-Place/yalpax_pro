import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yalpax_pro/feature/jobs/controllers/jobs_controller.dart';
import '../../../core/routes/routes.dart';
import '../../../core/utils/app_constants.dart';
import '../../auth/services/auth_service.dart';

class SplashController extends GetxController {
  late final SharedPreferences _prefs;
  late final AuthService _authService;
  final isInitialized = false.obs;
  Worker? _authStateWorker;

  @override
  void onInit() {
    super.onInit();
    _prefs = Get.find<SharedPreferences>();
    _authService = Get.put(AuthService());
    _initializeApp();
    
    // Listen to auth state changes
    _authStateWorker = ever(_authService.isAuthenticated, (bool isAuthenticated) {
      if (isInitialized.value) {
        _handleAuthStateChange(isAuthenticated);
      }
    });
  }

  @override
  void onClose() {
    _authStateWorker?.dispose();
    super.onClose();
  }

  Future<void> _initializeApp() async {
    try {
      debugPrint('Splash: Starting initialization');
      await _authService.initializeAuthState();

      // Check onboarding status only on first install or after app reset
      final hasCompletedOnboarding = _prefs.getBool(AppConstants.onboardingCompleteKey);
      debugPrint('Splash: Onboarding status: $hasCompletedOnboarding');

      // Only show onboarding if the flag is explicitly false or null (first install)
      if (hasCompletedOnboarding == null || hasCompletedOnboarding == false) {
        debugPrint('Splash: Navigating to onboarding');
        await Get.offAllNamed(Routes.onboarding);
        return;
      }

      // Initial navigation based on auth state
      _handleAuthStateChange(_authService.isAuthenticated.value);
    } catch (e, stackTrace) {
      debugPrint('Splash: Initialization error: $e');
      debugPrint('Stack trace: $stackTrace');
      await Get.offAllNamed(Routes.initial);
      Get.snackbar('Error', 'Failed to initialize app');
    } finally {
      isInitialized.value = true;
    }
  }

  void _handleAuthStateChange(bool isAuthenticated) {
    // Don't navigate if we're handling an OAuth callback
    if (Get.currentRoute.contains('login-callback')) {
      debugPrint('Splash: Skipping navigation during OAuth callback');
      return;
    }

    final currentRoute = Get.currentRoute;
    final nextRoute = isAuthenticated ? Routes.jobs : Routes.initial;
    
    debugPrint('Splash: Auth state changed. isAuthenticated: $isAuthenticated');
    debugPrint('Splash: Current route: $currentRoute, Next route: $nextRoute');
    
    // Only navigate if we're not already on the target route
    if (currentRoute != nextRoute) {
      debugPrint('Splash: Navigating to $nextRoute');
      Get.offAllNamed(nextRoute);
    }
  }
}