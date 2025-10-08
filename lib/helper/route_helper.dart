import 'package:efood_kitchen/features/auth/screens/login_screen.dart';
import 'package:efood_kitchen/features/home/screens/home_screen.dart';
import 'package:efood_kitchen/features/splash/screens/splash_screen.dart';
import 'package:get/get.dart';

class RouteHelper {
  static const String initial = '/';
  static const String splash = '/splash';
  static const String home = '/home';
  static const String login = '/login';
  static const String maintenance = '/maintenance';
  static const String orderDetails = '/OrderDetailsScreen';

  static getInitialRoute() => initial;
  static getSplashRoute() => splash;
  static getLoginRoute() => login;
  static getHomeRoute(String name) => '$home?name=$name';
  static getMaintenanceRoute() => maintenance;

  static List<GetPage> routes = [
    GetPage(name: initial, page: () => const SplashScreen()),
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
  ];
}