import 'dart:async';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/app_constants.dart';

class AuthService extends GetxService {
  final supabase = Supabase.instance.client;
  final logger = Logger();

  // Auth state observables
  final isAuthenticated = false.obs;
  final isLoading = false.obs;
  final currentUser = Rxn<User>();
  final authError = RxnString();

  // Stream subscription for auth state changes
  StreamSubscription<AuthState>? _authStateSubscription;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
    initializeAuthState();
    _setupAuthStateListener();
  }

  @override
  void onClose() {
    _authStateSubscription?.cancel();
    super.onClose();
  }

  void initializeAuthState() async {
    try {
      final session = supabase.auth.currentSession;
  

      // Check both session and stored auth state
      isAuthenticated.value = session != null && !session.isExpired;
      currentUser.value = session?.user;

      currentUser.value = supabase.auth.currentUser;

      if (currentUser.value != null) {
        logger.i('Current user id: ${currentUser.value!.id}');
        logger.i('Current user email: ${currentUser.value!.email}');

      
      } else {
        // Clear auth state if no current user

      }
    } catch (e) {
      logger.e('Error initializing auth state: $e');
    
      isAuthenticated.value = false;
      currentUser.value = null;
    }
  }

  void _setupAuthStateListener() {
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((
      data,
    ) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      switch (event) {
        case AuthChangeEvent.signedIn:
          isAuthenticated.value = true;
          currentUser.value = session?.user;
          await _saveAuthState(session);
          break;
        case AuthChangeEvent.signedOut:
          isAuthenticated.value = false;
          currentUser.value = null;
          await _clearAuthState();
          break;
        case AuthChangeEvent.tokenRefreshed:
          await _saveAuthState(session);
          break;
        case AuthChangeEvent.userDeleted:
          isAuthenticated.value = false;
          currentUser.value = null;
          await _clearAuthState();
          break;
        default:
          break;
      }
    });
  }

  Future<void> _saveAuthState(Session? session) async {
    try {
      final prefs = Get.find<SharedPreferences>();
      if (session != null) {
        await prefs.setString(AppConstants.userTokenKey, session.accessToken);
        await prefs.setBool('isAuthenticated', true);
      } else {
        await _clearAuthState();
      }
    } catch (e) {
      logger.e('Error saving auth state: $e');
    }
  }

  Future<void> _clearAuthState() async {
    try {
      final prefs = Get.find<SharedPreferences>();
      await prefs.remove(AppConstants.userTokenKey);
      await prefs.setBool('isAuthenticated', false);
    } catch (e) {
      logger.e('Error clearing auth state: $e');
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      isLoading.value = true;
      authError.value = null;

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        await _saveAuthState(response.session);
        return true;
      }
      return false;
    } catch (e) {
      authError.value = e.toString();
      logger.e('Sign in error: $e');
      return false;
    } finally {
      isLoading.value = false;
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

  void checkAuthStatus() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      isAuthenticated.value = true;
      currentUser.value = user;
    } else {
      isAuthenticated.value = false;
      currentUser.value = null;
    }
  }
}
