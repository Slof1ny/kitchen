import 'dart:async';

import 'package:efood_kitchen/features/auth/controllers/auth_controller.dart';
import 'package:efood_kitchen/common/controllers/theme_controller.dart';
import 'package:efood_kitchen/util/dimensions.dart';
import 'package:efood_kitchen/helper/animated_dialog_helper.dart';
import 'package:efood_kitchen/common/widgets/custom_rounded_button.dart';
import 'package:efood_kitchen/features/home/widgets/fab_circular_menu_widget.dart';
import 'package:efood_kitchen/common/widgets/logout_dialog_widget.dart';
import 'package:efood_kitchen/features/auth/screens/login_screen.dart';
import 'package:efood_kitchen/features/home/widgets/profile_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingWidget extends StatefulWidget {
  const SettingWidget({Key? key}) : super(key: key);

  @override
  State<SettingWidget> createState() => _SettingWidgetState();
}

class _SettingWidgetState extends State<SettingWidget> {
  final GlobalKey<FabCircularMenuWidgetState> _fabKey = GlobalKey();
  Timer? _timer;


  void changeButtonState() {
    if (_fabKey.currentState != null && _fabKey.currentState!.isOpen) {
      _fabKey.currentState?.close();
      _timer?.cancel();
      _timer = null;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      changeButtonState();
      timer.cancel();
    });

  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom : Dimensions.paddingSizeDefault),
      child: FabCircularMenuWidget(
        key: _fabKey,

        onDisplayChange: (isOpen) {
          if(isOpen){
            _startTimer();
          }
        },
        ringColor: Theme.of(context).cardColor.withValues(alpha:0.2),
        fabSize: 50,
        ringWidth: 90,
        fabOpenIcon: Icon(Icons.settings, color: Theme.of(context).cardColor),
        ringDiameter: 300,
        children: <Widget>[
          CustomRoundedButtonWidget(image: '', onTap: () {
            showAnimatedDialog(context: context,
                barrierDismissible: true,
                animationType: DialogTransitionType.slideFromBottomFade,
                builder: (BuildContext context){
                  return LogOutDialogWidget(
                    icon: Icons.exit_to_app_rounded, title: 'logout'.tr,
                    description: 'do_you_want_to_logout_from_this_account'.tr, onTapFalse:() => Navigator.of(context).pop(false),
                    onTapTrue:() {
                      Get.find<AuthController>().clearSharedData().then((condition) {
                        if(context.mounted) {
                          Navigator.pop(context);
                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
                        }

                      });
                    },
                    onTapTrueText: 'yes'.tr, onTapFalseText: 'no'.tr,
                  );
                });
          },
            widget: Icon(Icons.exit_to_app, color: Theme.of(context).primaryColor),
          ),

          CustomRoundedButtonWidget(image: '',
            onTap: () =>  Get.find<ThemeController>().toggleTheme(),
            widget: Icon(Icons.light_mode_outlined, color: Theme.of(context).primaryColor),
          ),

          CustomRoundedButtonWidget(image: '', onTap: () {showAnimatedDialog(context: context,
              barrierDismissible: true,
              animationType: DialogTransitionType.slideFromBottomFade,
              builder: (BuildContext context){
                return Dialog(
                    insetAnimationDuration: const Duration(milliseconds: 400),
                    insetAnimationCurve: Curves.easeIn,
                    elevation: 10,
                    backgroundColor: Theme.of(context).cardColor,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault))),
                    child: const SizedBox(width: 300,
                        child: ProfileDialogWidget()));
              });
          },
            widget: Icon(Icons.person, color: Theme.of(context).primaryColor),
          ),

        ],
      ),
    );
  }
}
