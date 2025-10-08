import 'package:efood_kitchen/features/splash/controllers/splash_controller.dart';
import 'package:efood_kitchen/helper/route_helper.dart';
import 'package:efood_kitchen/helper/custom_snackbar_helper.dart';
import 'package:get/get.dart';

class ApiChecker {
  static void checkApi(Response response) {
    if(response.statusCode == 401 || response.status.code == 401) {
      Get.toNamed(RouteHelper.login);
      Get.find<SplashController>().removeSharedData();
    }else{
      showCustomSnackBarHelper(response.statusText!);
    }
  }
}