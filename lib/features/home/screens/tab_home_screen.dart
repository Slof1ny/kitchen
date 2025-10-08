import 'package:efood_kitchen/features/auth/controllers/auth_controller.dart';
import 'package:efood_kitchen/features/order/controllers/order_controller.dart';
import 'package:efood_kitchen/common/controllers/theme_controller.dart';
import 'package:efood_kitchen/helper/responsive_helper.dart';
import 'package:efood_kitchen/util/dimensions.dart';
import 'package:efood_kitchen/util/images.dart';
import 'package:efood_kitchen/helper/animated_dialog_helper.dart';
import 'package:efood_kitchen/common/widgets/custom_app_bar_widget.dart';
import 'package:efood_kitchen/common/widgets/custom_loader_widget.dart';
import 'package:efood_kitchen/common/widgets/custom_rounded_button.dart';
import 'package:efood_kitchen/common/widgets/logout_dialog_widget.dart';
import 'package:efood_kitchen/features/home/widgets/search_widget.dart';
import 'package:efood_kitchen/features/auth/screens/login_screen.dart';
import 'package:efood_kitchen/features/home/widgets/order_status_tab_widget.dart';
import 'package:efood_kitchen/features/home/widgets/profile_dialog_widget.dart';
import 'package:efood_kitchen/features/order/widgets/tab_order_details_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/order_list_widget.dart';

class TabHomeScreen extends StatefulWidget {
  final TextEditingController searchEditController;
  final TabController? tabController;

  const TabHomeScreen({super.key, required this.searchEditController, this.tabController});
  @override
  State<TabHomeScreen> createState() => _TabHomeScreenState();
}

class _TabHomeScreenState extends State<TabHomeScreen> with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(
        builder: (orderController) {
          return Stack(
            children: [
              const CustomAppBarWidget(
                showCart: true, isBackButtonExist: true, onBackPressed: null, icon: '',
              ),

              Column(
                children: [

                  Flexible(
                    child: Row(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 4,
                            child: Column(
                              children: [
                                SizedBox(height: MediaQuery.of(context).viewPadding.top + (ResponsiveHelper.isSmallTab() ? 50 : 90),),

                                Row(
                                  children: [
                                    Expanded(child: SearchWidget(
                                      searchEditController: widget.searchEditController,
                                      tabController: widget.tabController,
                                    )),

                                    Expanded(child: OrderStatusTabWidget(searchTextController: widget.searchEditController)),
                                  ],
                                ),

                                Flexible(child: OrderListWidget(tabController: widget.tabController!)),




                              ],
                            )),

                        GetBuilder<OrderController>(
                            builder: (orderController) {
                              return Expanded(flex: 2,
                                  child: SafeArea(
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                        bottom: Dimensions.paddingSizeDefault,
                                        right: Dimensions.paddingSizeDefault,
                                        left: Dimensions.paddingSizeSmall,
                                      ),
                                      decoration: BoxDecoration(
                                        color:  Theme.of(context).cardColor, borderRadius: BorderRadius.circular(5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Get.isDarkMode ?  Theme.of(context).cardColor.withValues(alpha:0.1) : Colors.black.withValues(alpha:0.1),
                                            offset: const Offset(0, 3.75), blurRadius: 9.29,
                                          )
                                        ],
                                      ),

                                      child: Column(children: [
                                        ClipPath(
                                          clipper: _MovieTicketClipperPath(),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).primaryColor,
                                            ),
                                            height: 13,
                                          ),
                                        ),

                                        Expanded(
                                          child: orderController.isLoading ? const CustomLoaderWidget() : TabOrderDetailsWidget(
                                            orderId: orderController.orderId,
                                            orderStatus: orderController.orderStatus,
                                            orderNote: orderController.orderNote,
                                          ),
                                        ),


                                      ],),
                                    ),
                                  ));
                            }
                        ),
                      ],
                    ),
                  )




                ],
              ),

              Positioned.fill(child: Align(alignment: Alignment.bottomCenter, child: Padding(
                padding: EdgeInsets.all(
                  ResponsiveHelper.isSmallTab() ?
                  Dimensions.paddingSizeSmall : Dimensions.paddingSizeDefault,
                ),
                child: Row(children: [
                  CustomRoundedButtonWidget(image: Images.logOut, onTap: () {
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
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault,),

                  CustomRoundedButtonWidget(image: Images.themeIcon,
                    onTap: () =>  Get.find<ThemeController>().toggleTheme(),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault,),


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





                ],),
              ))),


            ],
          );
        }
    );
  }
}


class _MovieTicketClipperPath extends CustomClipper<Path> {
  @override

  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(-5, size.height);
    double x = -5;
    double y = size.height;
    double yControlPoint = size.height * .40;
    double increment = size.width / 40;

    while (x < size.width) {
      path.quadraticBezierTo(
        x + increment / 2, yControlPoint, x + increment, y,
      );
      x += increment;
    }

    path.lineTo(size.width, 0.0);


    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) => oldClipper != this;
}
