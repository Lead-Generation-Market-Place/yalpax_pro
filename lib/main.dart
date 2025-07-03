import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yalpax_pro/feature/jobs/controllers/jobs_controller.dart';

import 'core/controllers/theme_controller.dart';
import 'core/localization/localization.dart';
import 'core/routes/routes.dart' hide RouteObserver;
import 'core/services/service_bindings.dart';
import 'core/utils/app_constants.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final supabase = Supabase.instance.client;

Future<void> _initializeApp() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('Initializing app...');

    // System UI settings
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize Supabase first
    debugPrint('Initializing Supabase...');
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
      debug: kDebugMode,
    ).timeout(const Duration(seconds: 10), onTimeout: () {
      throw TimeoutException('Supabase initialization timed out');
    });
    debugPrint('Supabase initialized successfully');

    // Shared Preferences
    debugPrint('Initializing SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();
    await Get.putAsync(() => Future.value(prefs), permanent: true);

    // Initialize core services first
    debugPrint('Setting up core dependencies...');
    final serviceBindings = ServiceBindings();
    await serviceBindings.dependencies();

    // Theme Controller - after core services
    debugPrint('Initializing theme controller...');
    final themeController = Get.put(ThemeController(), permanent: true);
    await themeController.initTheme();

    debugPrint('App initialization complete');
  } catch (e, stackTrace) {
    debugPrint('Error during initialization: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow; // Rethrow to be caught by runZonedGuarded
  }
}

void main() {
  runZonedGuarded(
    () async {

      await _initializeApp();
      debugPrint('Starting app...');
      runApp(const MyApp());
    },
    (error, stackTrace) {
      debugPrint('Unhandled Error: $error');
      debugPrint('StackTrace: $stackTrace');
      // Optionally report to an external service like Sentry, Firebase Crashlytics
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return GetMaterialApp(
      title: AppConstants.appName,
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,

      // Localization
      translations: LocalizationService(),
      locale: LocalizationService.locale,
      fallbackLocale: LocalizationService.fallbackLocale,

      // Themes
      theme: ThemeController.lightTheme,
      darkTheme: ThemeController.darkTheme,
      themeMode: themeController.themeMode,

      // Routing
      initialRoute: Routes.splash,
      getPages: AppPages.pages,
      defaultTransition: Transition.fade,
      navigatorObservers: [Get.put(RouteObserver<Route>())],

      // Unknown Route
      onUnknownRoute: (settings) => GetPageRoute(
        page: () => _UnknownRouteScreen(routeName: settings.name),
      ),

      // Error Handling and Screen Adaptation
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return _ErrorScreen(details: details);
        };

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },

      // Logging
      routingCallback: (routing) {
        if (routing?.current != null) {
          debugPrint('Navigation: ${routing?.previous} -> ${routing?.current}');
          _trackScreenView(routing!.current!);
        }
      },
    );
  }

  void _trackScreenView(String screenName) {
    debugPrint('Screen View: $screenName');
  }
}

// Error Screen Widget
class _ErrorScreen extends StatelessWidget {
  final FlutterErrorDetails details;

  const _ErrorScreen({required this.details, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView( // For very small screens
          padding: const EdgeInsets.all(24.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 24,
            runSpacing: 24,
            children: [
              Icon(
                Icons.error_outline,
                color: Get.theme.colorScheme.error,
                size: 64,
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Something went wrong'.tr,
                      style: Get.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (kDebugMode)
                      Text(
                        details.exception.toString(),
                        style: Get.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Get.offAllNamed(Routes.jobs),
                      child: Text('Restart App'.tr),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}



// Unknown Route Screen Widget
class _UnknownRouteScreen extends StatelessWidget {
  final String? routeName;

  const _UnknownRouteScreen({this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Get.theme.colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found: $routeName'.tr,
              style: Get.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Get.offAllNamed(Routes.jobs),
              child: Text('Go to Home'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
