import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:efood_kitchen/features/auth/controllers/auth_controller.dart';
import 'package:efood_kitchen/features/splash/controllers/splash_controller.dart';
import 'package:efood_kitchen/helper/custom_snackbar_helper.dart';
import 'package:efood_kitchen/helper/route_helper.dart';
import 'package:efood_kitchen/util/app_constants.dart';
import 'package:efood_kitchen/util/images.dart';
import 'package:efood_kitchen/util/styles.dart';
import 'package:efood_kitchen/common/widgets/curved_painter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<List<ConnectivityResult>>? subscription;


  @override
  void initState() {
    super.initState();


    _checkConnectivity();
    Get.find<SplashController>().initSharedData();
    _route();

  }

  @override
  void dispose() {
    super.dispose();

  }

  void _route() {

    Get.find<SplashController>().getConfigData().then((value) {
      Timer(const Duration(seconds: 1), () async {
        if(Get.find<AuthController>().isLoggedIn()){
          Get.find<AuthController>().getProfile();
          Get.offNamed(RouteHelper.home);

        }else{
          Get.offNamed(RouteHelper.login);

        }


      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _globalKey,
      body: Stack(
        children: [
          Positioned(

            child: Align(
              alignment: Alignment.bottomCenter,
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 300),
                painter: CurvedPainter(),
              ),
            ),
          ),
          Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                Image.asset(Images.logo, height: 175),
                Image.asset(Images.logoName, height: 50),
                Text(AppConstants.appName, style: robotoBlack.copyWith(color: Theme.of(context).primaryColor)),

                const Spacer(),

              ],
            ),
          ),
        ],
      ),
    );
  }

  void _checkConnectivity() {
    bool isFirst = true;
    subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      bool isConnected = result.contains(ConnectivityResult.wifi)  || result.contains(ConnectivityResult.mobile);

      if((isFirst && !isConnected) || !isFirst && context.mounted) {
        showCustomSnackBarHelper(isConnected ?  'connected'.tr : 'no_connection'.tr , isError: !isConnected);


        if(isConnected && '/SplashScreen' == Get.currentRoute) {
          _route();
        }
      }
      isFirst = false;


    });

  }

}
