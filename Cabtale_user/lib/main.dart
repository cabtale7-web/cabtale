import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/helper/notification_helper.dart';
import 'package:ride_sharing_user_app/helper/responsive_helper.dart';
import 'package:ride_sharing_user_app/helper/di_container.dart' as di;
import 'package:ride_sharing_user_app/helper/route_helper.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/localization/messages.dart';
import 'package:ride_sharing_user_app/theme/dark_theme.dart';
import 'package:ride_sharing_user_app/theme/light_theme.dart';
import 'package:ride_sharing_user_app/theme/theme_controller.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  if (ResponsiveHelper.isMobilePhone) {
    HttpOverrides.global = MyHttpOverrides();
  }
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // 70km

  //firebase crashlytics
  // FlutterError.onError = (errorDetails) {
  //   FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  // };

  // PlatformDispatcher.instance.onError = (error, stack) {
  //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //   return true;
  // };

  Map<String, Map<String, String>> languages = await di.init();

  await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
  await FirebaseMessaging.instance.requestPermission();
  FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(MyApp(languages: languages));
}

class MyApp extends StatelessWidget {
  final Map<String, Map<String, String>> languages;
  const MyApp({super.key, required this.languages});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(builder: (themeController) {
      return GetBuilder<LocalizationController>(builder: (localizeController) {
        return GetMaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            navigatorKey: Get.key,
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
            ),
            theme: themeController.darkTheme ? darkTheme() : lightTheme(),
            locale: localizeController.locale,
            initialRoute: RouteHelper.getSplashRoute(),
            getPages: RouteHelper.routes,
            translations: Messages(languages: languages),
            fallbackLocale: Locale(AppConstants.languages[0].languageCode,
                AppConstants.languages[0].countryCode),
            defaultTransition: Transition.fadeIn,
            transitionDuration: const Duration(milliseconds: 500),
            builder: (context, child) {
              return MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.noScaling),
                  child: child!);
            });
      });
    });
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

// import 'dart:io';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
// import 'package:ride_sharing_user_app/features/auth/screens/forgot_password_screen.dart';
// import 'package:ride_sharing_user_app/features/auth/screens/sign_in_screen.dart';
// import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
// import 'package:ride_sharing_user_app/features/home/screens/home_screen.dart';
// import 'package:ride_sharing_user_app/helper/notification_helper.dart';
// import 'package:ride_sharing_user_app/helper/responsive_helper.dart';
// import 'package:ride_sharing_user_app/helper/di_container.dart' as di;
// import 'package:ride_sharing_user_app/helper/route_helper.dart';
// import 'package:ride_sharing_user_app/localization/localization_controller.dart';
// import 'package:ride_sharing_user_app/localization/messages.dart';
// import 'package:ride_sharing_user_app/theme/dark_theme.dart';
// import 'package:ride_sharing_user_app/theme/light_theme.dart';
// import 'package:ride_sharing_user_app/theme/theme_controller.dart';
// import 'package:ride_sharing_user_app/util/app_constants.dart';
//
// // Import your main screen widgets
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
// void main() async {
//   if (ResponsiveHelper.isMobilePhone) {
//     HttpOverrides.global = MyHttpOverrides();
//   }
//
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   Map<String, Map<String, String>> languages = await di.init();
//   await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
//   await FirebaseMessaging.instance.requestPermission();
//   FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
//   await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//
//   runApp(MyApp(languages: languages));
// }
//
// // Main app controlling theme, localization, and initial screen
// class MyApp extends StatefulWidget {
//   final Map<String, Map<String, String>> languages;
//   const MyApp({super.key, required this.languages});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   bool _showSplash = true;
//
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(seconds: 3), () {
//       setState(() {
//         _showSplash = false; // Switch to main app after splash
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<ThemeController>(builder: (themeController) {
//       return GetBuilder<LocalizationController>(builder: (localizeController) {
//         return GetMaterialApp(
//           title: AppConstants.appName,
//           debugShowCheckedModeBanner: false,
//           navigatorKey: Get.key,
//           scrollBehavior: const MaterialScrollBehavior().copyWith(
//             dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
//           ),
//           theme: themeController.darkTheme ? darkTheme() : lightTheme(),
//           locale: localizeController.locale,
//           translations: Messages(languages: widget.languages),
//           fallbackLocale: Locale(
//             AppConstants.languages[0].languageCode,
//             AppConstants.languages[0].countryCode,
//           ),
//           defaultTransition: Transition.fadeIn,
//           transitionDuration: const Duration(milliseconds: 500),
//           builder: (context, child) {
//             return MediaQuery(
//               data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
//               child: child!,
//             );
//           },
//           // Show splash first, then SignInScreen/DashboardScreen
//           home: _showSplash
//               ? const SplashScreen()
//               : DashboardScreen(), // <-- replace with DashboardScreen() if needed
//         );
//       });
//     });
//   }
// }
//
// // SplashScreen widget with theme support
// class SplashScreen extends StatelessWidget {
//   const SplashScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // Uses current app theme
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body: Center(
//         child: Text(
//           "Splash Screen",
//           style: TextStyle(
//             fontSize: 28,
//             fontWeight: FontWeight.bold,
//             color: Theme.of(context).primaryColor,
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // HttpOverrides for certificate issues
// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
//   }
// }
