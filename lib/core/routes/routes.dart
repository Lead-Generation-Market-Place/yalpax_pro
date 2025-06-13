import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:yalpax_pro/feature/auth/views/login.dart';
import 'package:yalpax_pro/feature/auth/views/reset_password.dart';
import 'package:yalpax_pro/feature/auth/views/reset_password_token.dart';
import 'package:yalpax_pro/feature/auth/views/signup.dart';
import 'package:yalpax_pro/feature/auth/views/signup/first_step.dart';
import 'package:yalpax_pro/feature/auth/views/signup/fourth_step.dart';
import 'package:yalpax_pro/feature/auth/views/signup/second_step.dart';
import 'package:yalpax_pro/feature/auth/views/signup/third_step.dart';
import 'package:yalpax_pro/feature/initial_page/controllers/initial_binding.dart';
import 'package:yalpax_pro/feature/initial_page/views/initial_view.dart';
import 'package:yalpax_pro/feature/jobs/controllers/jobs_binding.dart';
import 'package:yalpax_pro/feature/jobs/views/jobs_view.dart';
import 'package:yalpax_pro/feature/profile/views/profile_view.dart';
import 'package:yalpax_pro/feature/messages/views/message_view.dart';
import 'package:yalpax_pro/feature/one_time_initial_view/controllers/one_time_initial_binding.dart';
import 'package:yalpax_pro/feature/services/views/services_view.dart';
import 'package:yalpax_pro/feature/messages/controllers/messages_binding.dart';

import 'package:yalpax_pro/feature/settings/views/settings_view.dart';
import 'package:yalpax_pro/feature/notifications/views/notification_view.dart';

import '../../feature/splash/views/splash_view.dart';
import '../../feature/splash/controllers/splash_controller.dart';
import '../../feature/one_time_initial_view/views/one_time_initial_view.dart';

import '../../feature/auth/controllers/auth_binding.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Route Names
abstract class Routes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const initial = '/initial';

  static const login = '/login';
  static const signup = '/signup';
  static const jobs = '/jobs';
  static const profile = '/profile';
  static const settings = '/settings';
  static const messages = '/messages';
  static const services = '/services';

  static const notification = '/notification';
  static const resetPassword = '/reset-password';
  static const resetPasswordToken = '/reset-password-token';
  static const firstStep = '/firstStep';
  static const secondStep = '/secondStep';
  static const thirdStep = '/thirdStep';
  static const fourthStep = '/fourthStep';
}

// Middleware
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;
    
    if (session == null) {
      return const RouteSettings(name: Routes.login);
    }
    return null;
  }
}

class NoAuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;
    
    if (session != null) {
      return const RouteSettings(name: Routes.jobs);
    }
    return null;
  }
}

// App Pages
abstract class AppPages {
  static final pages = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: BindingsBuilder(() {
        Get.put(SplashController());
      }),
      transition: Transition.fade,
    ),

    GetPage(
      name: Routes.onboarding,
      page: () => const OneTimeInitialView(),
      binding: OneTimeInitialBinding(),
      transition: Transition.fadeIn,
    ),

    // Auth Pages
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
      middlewares: [NoAuthMiddleware()],
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: Routes.signup,
      page: () => SignupView(),
      middlewares: [NoAuthMiddleware()],
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: Routes.jobs,
      page: () => JobsView(),
      // middlewares: [AuthMiddleware()],
      binding: JobsBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: Routes.profile,
      page: () => ServicesView(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: Routes.signup,
      page: () => SignupView(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: Routes.messages,
      page: () => MessageView(),
      middlewares: [AuthMiddleware()],
      binding: MessagesBinding(),
      transition: Transition.downToUp,
    ),

    GetPage(
      name: Routes.services,
      page: () => ServicesView(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: Routes.settings,
      page: () => SettingsView(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.profile,
      page: () => ProfileView(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.notification,
      page: () => NotificationView(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.initial,
      page: () => InitialView(),

      binding: InitialBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: Routes.resetPassword,
      page: () => ResetPassword(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.resetPasswordToken,
      page: () => ResetPasswordToken(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.firstStep,
      page: () => FirstStep(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.secondStep,
      page: () => SecondStep(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.thirdStep,
      page: () => ThirdStep(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.fourthStep,
      page: () => FourthStep(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}



// Route Observer
class RouteObserver extends GetObserver {
  @override
  void onPageCalled(Route? route, Route? previousRoute) {
    debugPrint('New route called: ${route?.settings.name}');
  }

  @override
  void onPagePopped(Route? route, Route? previousRoute) {
    debugPrint('Page popped: ${route?.settings.name}');
  }
}
