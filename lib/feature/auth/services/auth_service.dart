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
    initializeAuthState();
    _setupAuthStateListener();
  }

  @override
  void onClose() {
    _authStateSubscription?.cancel();
    super.onClose();
  }

  void initializeAuthState() {
    final session = supabase.auth.currentSession;
    isAuthenticated.value = session != null && !session.isExpired && isAuthenticated.value  != false;
    currentUser.value = supabase.auth.currentUser;

    if (currentUser.value != null) {
      logger.i('Current user id: ${currentUser.value!.id}');
      logger.i('Current user email: ${currentUser.value!.email}');
    }
  }

  void _setupAuthStateListener() {
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      switch (event) {
        case AuthChangeEvent.signedIn:
          isAuthenticated.value = true;
          currentUser.value = session?.user;
          _saveAuthState(session);
          break;
        case AuthChangeEvent.signedOut:
          isAuthenticated.value = false;
          currentUser.value = null;
          _clearAuthState();
          break;

        case AuthChangeEvent.tokenRefreshed:
          _saveAuthState(session);
          break;

        default:
          break;
      }
    });
  }

  Future<void> _saveAuthState(Session? session) async {
    if (session != null) {
      final prefs = Get.find<SharedPreferences>();
      await prefs.setString(AppConstants.userTokenKey, session.accessToken);
    }
  }

  Future<void> _clearAuthState() async {
    final prefs = Get.find<SharedPreferences>();
    await prefs.remove(AppConstants.userTokenKey);
  }

  Future<bool> signIn(String email, String password) async {
    try {
      isLoading.value = true;
      authError.value = null;

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response.session != null;
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
