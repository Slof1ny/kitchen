import 'dart:async';
import 'dart:io';
import 'package:efood_kitchen/common/controllers/localization_controller.dart';
import 'package:efood_kitchen/common/controllers/theme_controller.dart';
import 'package:efood_kitchen/helper/notification_helper.dart';
import 'package:efood_kitchen/helper/route_helper.dart';
import 'package:efood_kitchen/theme/dark_theme.dart';
import 'package:efood_kitchen/theme/light_theme.dart';
import 'package:efood_kitchen/util/app_constants.dart';
import 'package:efood_kitchen/util/messages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:url_strategy/url_strategy.dart';
import 'helper/get_di.dart' as di;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  if(!GetPlatform.isWeb) {
    HttpOverrides.global = MyHttpOverrides();
  }
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  if(defaultTargetPlatform == TargetPlatform.iOS){
    await Firebase.initializeApp();

  }else {
    await Firebase.initializeApp(options: const FirebaseOptions(
      apiKey: 'AIzaSyA40XT2LSjEI_V9LCfp8YDE2qN_P9Fcduw', //current_key
      appId: '1:384321080318:android:99029e94d817a9ae2c0eaf', // mobilesdk_app_id
      messagingSenderId: '384321080318', // project_number
      projectId: 'gem-b5006', // project_id
    ));
  }

  ///firebase crashlytics
  // FlutterError.onError = (errorDetails) {
  //   FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  // };
  //
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //   return true;
  // };

  if(defaultTargetPlatform == TargetPlatform.android){
    FirebaseMessaging.instance.requestPermission();
  }

  Map<String, Map<String, String>> languages = await di.init();

  int? orderID;
  try {
    if (GetPlatform.isMobile) {
      final NotificationAppLaunchDetails? notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
      if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
        orderID = notificationAppLaunchDetails?.notificationResponse?.payload != null
            ? int.parse('${notificationAppLaunchDetails?.notificationResponse?.payload}') : null;
      }
      await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    }
  }catch(e) {
    debugPrint('$e');
  }

  runApp(MyApp(languages: languages, orderID: orderID));
}

class MyApp extends StatelessWidget {
  final Map<String, Map<String, String>>? languages;
  final int? orderID;
  const MyApp({super.key, @required this.languages, required this.orderID});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(builder: (themeController) {
      return GetBuilder<LocalizationController>(builder: (localizeController) {
        return SafeArea(top: false, child: GetMaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          navigatorKey: Get.key,
          theme: themeController.darkTheme ? dark : light,
          locale: localizeController.locale,
          translations: Messages(languages: languages!),
          fallbackLocale: Locale(AppConstants.languages[0].languageCode!, AppConstants.languages[0].countryCode),
          initialRoute: RouteHelper.splash,
          getPages: RouteHelper.routes,
          defaultTransition: Transition.topLevel,
          transitionDuration: const Duration(milliseconds: 500),
        ));
      },
      );
    },
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
