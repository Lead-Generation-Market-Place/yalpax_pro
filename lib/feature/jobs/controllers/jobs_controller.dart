import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';

class JobsController extends GetxController {
  final supabase = Supabase.instance.client;
  var isStep = false.obs;
  var isCount = 0.obs;
  var isLoading = false.obs;
  var isNavigating = false.obs;
  late final AuthController authController = Get.put(
    AuthController(),
    permanent: true,
  );

  @override
  void onInit() async {
    super.onInit();

    isLoading.value = true;
    try {
      await checkStatus();
      // await checkStep();
    } catch (e) {
      debugPrint('Error in onInit: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // New method for direct navigation
  Future<void> navigateToJobs() async {
    isNavigating.value = true;
    await Get.offAllNamed(Routes.jobs);
    isNavigating.value = false;
  }

  Future<void> checkStatus() async {
    if (isNavigating.value) return;

    final currentUser = Supabase.instance.client.auth.currentUser;

    // User is authenticated, check for pro services
    try {
      final userExists = await supabase
          .from('users_profiles')
          .select()
          .eq('id', currentUser!.id)
          .maybeSingle()
          .limit(1);

      if (userExists == null) {
        Get.offAllNamed(Routes.login);
        return;
      } 
      final proServiceResponse = await supabase
          .from('pro_services')
          .select()
          .eq('user_id', currentUser.id)
          .maybeSingle()
          .limit(1);

      if (proServiceResponse == null) {
        debugPrint('No service found for user');
        isStep.value = true;

        await Get.offAllNamed(Routes.login);
        return;
      }

      // Check for phone number
      final userProfile = await supabase
          .from('users_profiles')
          .select()
          .eq('id', currentUser.id)
          .maybeSingle();

      if (userProfile == null ||
          userProfile['phone_number'] == null ||
          userProfile['phone_number'].toString().trim().isEmpty) {
        debugPrint('No phone number found for user');
        await Get.offAllNamed(Routes.thirdStep);
        return;
      }

      // If all checks pass, no navigation needed
    } catch (e) {
      debugPrint('Error checking status: $e');
      if (!isNavigating.value) {
        await Get.offAllNamed(Routes.initial);
      }
    }
  }

  Future<int> checkStep() async {
    if (isLoading.value) return isCount.value;

    isLoading.value = true;
    final currentUser = Supabase.instance.client.auth.currentUser;
    try {
      final userProfile = await supabase
          .from('users_profiles')
          .select()
          .eq('id', currentUser!.id)
          .maybeSingle();

      if (userProfile == null ) {
        debugPrint('No user profile found');
        isCount.value = 0;
        return isCount.value;
      } 

      final phoneNumber = userProfile!['phone_number']?.toString().trim();
      if (phoneNumber == null || phoneNumber.isEmpty) {
        debugPrint('No phone number found for user');
        isCount.value = 1;
        return isCount.value;
      }

      // User has profile and phone - increment count
      isCount.value = 1;

      final jobPreferences = await supabase
          .from('service_providers')
          .select()
          .eq('user_id', currentUser.id)
          .maybeSingle();

      if (jobPreferences == null) {
        debugPrint('No job preferences found');
        return isCount.value;
      }

      final proBusinessHours = await supabase
          .from('provider_business_hours')
          .select()
          .eq('provider_id', jobPreferences['provider_id']);

      if (proBusinessHours == null || proBusinessHours.isEmpty) {
        debugPrint('No business hours found');
        return isCount.value;
      }

      // User has job preferences and business hours - increment count
      isCount.value = 2;

      final providerReviews = await supabase
          .from('reviews')
          .select()
          .eq('providerUser_id', currentUser.id);

      if (providerReviews == null || providerReviews.isEmpty) {
        debugPrint('No Reviews');
        return isCount.value;
      }

      // User has everything complete - increment count
      isCount.value = 3;
      return isCount.value;
    } catch (e) {
      debugPrint('checkStep error: $e');
      return isCount.value;
    } finally {
      isLoading.value = false;
    }
  }
}
