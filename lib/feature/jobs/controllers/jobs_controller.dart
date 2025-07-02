import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yalpax_pro/core/routes/routes.dart';

class JobsController extends GetxController {
  var isStep  = false.obs;
  @override
  void onInit() {
    super.onInit();
    checkStatus();
  }

  Future<void> checkStatus() async {
    final currentUser = Supabase.instance.client.auth.currentUser!.id;
    if (currentUser == null) {
      debugPrint('Splash: No user found, navigating to initial');
      await Get.offAllNamed(Routes.initial);
      return;
    }

    // User is authenticated, check for pro services
    try {
      final proServiceResponse = await Supabase.instance.client
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
      final userProfile = await Supabase.instance.client
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
}
