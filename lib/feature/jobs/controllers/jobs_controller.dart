import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/main.dart';

class JobsController extends GetxController {
  final supabase = Supabase.instance.client;
  final currentUser = Supabase.instance.client.auth.currentUser!.id;
  var isStep = false.obs;
  var isCount = 0.obs;
  var isLoading = false.obs;
  @override
  void onInit() async{
    super.onInit();
  await  checkStep();
    checkStatus();
  }

  Future<void> checkStatus() async {
    if (currentUser == null) {
      debugPrint('Splash: No user found, navigating to initial');
      await Get.offAllNamed(Routes.initial);
      return;
    }

    // User is authenticated, check for pro services
    try {
      final proServiceResponse = await supabase
          .from('pro_services')
          .select()
          .eq('user_id', currentUser)
          .limit(1)
          .maybeSingle();

      if (proServiceResponse == null) {
        debugPrint('No service found for user');
        isStep.value = true;
        await Get.offAllNamed(Routes.firstStep);
        return;
      }

      // Check for phone number
      final userProfile = await supabase
          .from('users_profiles')
          .select()
          .eq('id', currentUser)
          .maybeSingle();

      if (userProfile == null ||
          userProfile['phone_number'] == null ||
          userProfile['phone_number'].toString().trim().isEmpty) {
        debugPrint('No phone number found for user');
        await Get.offAllNamed(Routes.thirdStep);
        return;
      }

      // If all checks pass, navigate to jobs
    } catch (e) {
      debugPrint('Error checking status: $e');
      await Get.offAllNamed(Routes.initial);
    }
  }

  Future<int> checkStep() async {
  try {
    final userProfile = await supabase
        .from('users_profiles')
        .select()
        .eq('id', currentUser)
        .maybeSingle();

    if (userProfile == null) {
      debugPrint('No user profile found');
      isCount.value = 1;
      return isCount.value;
    }

    final phoneNumber = userProfile!['phone_number']?.toString().trim();
    if (phoneNumber == null || phoneNumber.isEmpty) {
      debugPrint('No phone number found for user');
      isCount.value = 1;
      return isCount.value;
    }

    final jobPreferences = await supabase
        .from('service_providers')
        .select()
        .eq('user_id', currentUser)
        .maybeSingle().limit(1);

    if (jobPreferences == null) {
      debugPrint('No job preferences found');
      isCount.value = 2;  // Or another count if you want
      return isCount.value;
    }

    final proBusinessHours = await supabase
        .from('provider_business_hours')
        .select()
        .eq('provider_id', jobPreferences['provider_id']);

    if (proBusinessHours == null || proBusinessHours.isEmpty) {
      debugPrint('No business hours found');
      isCount.value = 2;  // Set as needed
      return isCount.value;
    }


    return isCount.value;

  } catch (e) {
    debugPrint('checkStep error: $e');
    return isCount.value;
  } finally {
    isLoading.value = false;
  }
}

}
