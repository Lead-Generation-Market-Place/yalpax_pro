import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';
import '../../../core/routes/routes.dart';
import '../../../core/utils/app_constants.dart';
import '../../auth/services/auth_service.dart';

class SplashController extends GetxController {
  late final SharedPreferences _prefs;
  late final AuthService _authService;
  late final AuthController authController;
  final isInitialized = false.obs;
  Worker? _authStateWorker;

  @override
  void onInit() {
    super.onInit();
    _prefs = Get.find<SharedPreferences>();
    _authService = Get.find<AuthService>();
    authController = Get.find<AuthController>();
    
    // Use Future.delayed to ensure widget tree is built
    Future.delayed(Duration.zero, () {
      _initializeApp();
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
      
      // Check SharedPreferences first for auth state
      final isAuthenticated = _prefs.getBool('isAuthenticated') ?? false;
      
      final session = Supabase.instance.client.auth.currentSession;
      final user = Supabase.instance.client.auth.currentUser;
      
      if (user != null && session != null && !session.isExpired) {
        // Check if user has completed profile setup
        final userProfile = await Supabase.instance.client
            .from('users_profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (userProfile == null) {
          // New user, needs to complete profile
          await Get.offAllNamed(Routes.firstStep);
          return;
        } else {
          // Existing user, check service provider status
          final proServices = await Supabase.instance.client
              .from('pro_services')
              .select()
              .eq('user_id', user.id);

          if (proServices.isEmpty) {
            // No services selected, go to first step
            await Get.offAllNamed(Routes.firstStep);
          } else {
            // Services exist, go to jobs
            await Get.offAllNamed(Routes.jobs);
          }
          return;
        }
      }

      // Not authenticated or session expired
      final hasCompletedOnboarding = _prefs.getBool(
        AppConstants.onboardingCompleteKey,
      );
      debugPrint('Splash: Onboarding status: $hasCompletedOnboarding');

      if (hasCompletedOnboarding == null || hasCompletedOnboarding == false) {
        debugPrint('Splash: Navigating to onboarding');
        await Get.offAllNamed(Routes.onboarding);
        return;
      }

      // Default to initial route
      await Get.offAllNamed(Routes.initial);
    } catch (e, stackTrace) {
      debugPrint('Splash: Initialization error: $e');
      debugPrint('Stack trace: $stackTrace');
      // Use Future.delayed to avoid navigation during build
      Future.delayed(Duration.zero, () {
        Get.offAllNamed(Routes.initial);
        Get.snackbar('Error', 'Failed to initialize app');
      });
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
      // Use Future.delayed to avoid navigation during build
      Future.delayed(Duration.zero, () {
        Get.offAllNamed(nextRoute);
      });
    }
  }
}
