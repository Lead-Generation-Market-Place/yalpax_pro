import 'dart:async';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/routes/routes.dart';
import '../../../core/utils/app_constants.dart';
import '../controllers/auth_controller.dart';

class AuthService extends GetxService {
  final supabase = Supabase.instance.client;
  final logger = Logger();

  // Auth state observables
  final isAuthenticated = false.obs;
  final isLoading = false.obs;
  final currentUser = Rxn<User>();
  final authError = RxnString();
  final isHandlingOAuth = false.obs;

  // Stream subscription for auth state changes
  StreamSubscription<AuthState>? _authStateSubscription;

  @override
  void onInit() {
    super.onInit();
    initializeAuthState();
    _setupAuthStateListener();
  }

  @override
  void onClose() {
    _authStateSubscription?.cancel();
    super.onClose();
  }

  Future<void> initializeAuthState() async {
    try {
      final session = supabase.auth.currentSession;
      final user = supabase.auth.currentUser;

      // Update auth state based on both session and current user
      final bool isValid =
          session != null && !session.isExpired && user != null;

      isAuthenticated.value = isValid;
      currentUser.value = isValid ? user : null;

      if (currentUser.value != null) {
        logger.i('Current user id: ${currentUser.value!.id}');
        logger.i('Current user email: ${currentUser.value!.email}');

        // Also verify the stored auth state
        final prefs = Get.find<SharedPreferences>();
        final storedToken = prefs.getString(AppConstants.userTokenKey);
        final storedAuthState = prefs.getBool('isAuthenticated') ?? false;

        if (!storedAuthState || storedToken == null) {
          await _saveAuthState(session); // Ensure preferences are in sync
        }
      } else {
        logger.i('No authenticated user found');
        isAuthenticated.value = false;
        await _clearAuthState();
      }
    } catch (e) {
      logger.e('Error initializing auth state: $e');
      isAuthenticated.value = false;
      currentUser.value = null;
      await _clearAuthState();
      rethrow;
    }
  }

  void _setupAuthStateListener() {
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((
      data,
    ) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      logger.i('Auth state changed: $event');

      try {
        switch (event) {
          case AuthChangeEvent.signedIn:
            if (session != null) {
              await _saveAuthState(session);
              currentUser.value = session.user;
              isAuthenticated.value = true;

              // Handle OAuth callback navigation only if not already handling
              if (!isHandlingOAuth.value && (Get.currentRoute.contains('login-callback') || Get.currentRoute.contains('code='))) {
                isHandlingOAuth.value = true;
                try {
                  final authController = Get.find<AuthController>();
                  final user = session.user;
                  final name =
                      user.userMetadata?['name'] ??
                      user.userMetadata?['full_name'] ??
                      user.userMetadata?['preferred_username'] ??
                      user.userMetadata?['given_name'];

                  if (name != null && name.toString().trim().isNotEmpty) {
                    await authController.handlePostLogin(
                      user: user,
                      usernameFromOAuth: name.toString(),
                    );
                  } else {
                    await Get.offAllNamed(Routes.jobs);
                  }
                } finally {
                  isHandlingOAuth.value = false;
                }
              }
            }
            break;
          case AuthChangeEvent.signedOut:
            await _clearAuthState();
            currentUser.value = null;
            isAuthenticated.value = false;
            break;
          case AuthChangeEvent.tokenRefreshed:
            if (session != null && !session.isExpired) {
              await _saveAuthState(session);
              currentUser.value = session.user;
              isAuthenticated.value = true;
            } else {
              await _clearAuthState();
              currentUser.value = null;
              isAuthenticated.value = false;
            }
            break;
          case AuthChangeEvent.userDeleted:
            await _clearAuthState();
            currentUser.value = null;
            isAuthenticated.value = false;
            break;
          default:
            break;
        }
      } catch (e) {
        logger.e('Error handling auth state change: $e');
        // Ensure we're in a consistent state even if there's an error
        isAuthenticated.value = session != null && !session.isExpired;
        currentUser.value = session?.user;
      }
    });
  }

  Future<void> _saveAuthState(Session? session) async {
    try {
      final prefs = Get.find<SharedPreferences>();
      if (session != null) {
        await prefs.setString(AppConstants.userTokenKey, session.accessToken);
        await prefs.setBool('isAuthenticated', true);
        logger.i('Auth state saved successfully');
      } else {
        await _clearAuthState();
      }
    } catch (e) {
      logger.e('Error saving auth state: $e');
      rethrow;
    }
  }

  Future<void> _clearAuthState() async {
    try {
      final prefs = Get.find<SharedPreferences>();
      await prefs.remove(AppConstants.userTokenKey);
      await prefs.remove('selected_service_ids');
      await prefs.setBool('isAuthenticated', false);
      logger.i('Auth state cleared successfully');
    } catch (e) {
      logger.e('Error clearing auth state: $e');
    }
  }

  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await supabase.auth.signOut();
      await _clearAuthState();
    } catch (e) {
      authError.value = e.toString();
      logger.e('Sign out error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      isLoading.value = true;
      authError.value = null;

      await supabase.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      authError.value = e.toString();
      logger.e('Password reset error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    try {
      isLoading.value = true;
      authError.value = null;

      await supabase.auth.updateUser(UserAttributes(password: newPassword));
      return true;
    } catch (e) {
      authError.value = e.toString();
      logger.e('Password update error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
