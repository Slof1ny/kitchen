import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:efood_kitchen/features/order/controllers/order_controller.dart';
import 'package:efood_kitchen/helper/notification_helper.dart';
import 'package:efood_kitchen/helper/responsive_helper.dart';
import 'package:efood_kitchen/util/dimensions.dart';
import 'package:efood_kitchen/util/images.dart';
import 'package:efood_kitchen/util/styles.dart';
import 'package:efood_kitchen/helper/animated_dialog_helper.dart';
import 'package:efood_kitchen/common/widgets/custom_search_field_widget.dart';
import 'package:efood_kitchen/common/widgets/logout_dialog_widget.dart';
import 'package:efood_kitchen/features/home/screens/tab_home_screen.dart';
import 'package:efood_kitchen/features/home/widgets/order_list_widget.dart';
import 'package:efood_kitchen/features/home/widgets/setting_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  final bool fromFilter;
  const HomeScreen({super.key,  this.fromFilter = false});


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin{
  TextEditingController searchController = TextEditingController();
  FocusNode searchControllerNode  = FocusNode();
  TabController? _tabController;
  late final AppLifecycleListener _listener;



  Future<void> loadData()async {
    await Get.find<OrderController>().getOrderList(1);
  }

  @override
  void initState() {
    super.initState();

    _listener = AppLifecycleListener(
      onResume: stopService,
    );
    if(!widget.fromFilter){
      loadData();
    }

    _tabController = TabController(
      length: 4, initialIndex: !widget.fromFilter
        ? 0: Get.find<OrderController>().currentIndex,vsync: this,
    );


    _tabController?.addListener((){
      if(_tabController?.indexIsChanging != null && _tabController!.indexIsChanging) {

      }else{
        switch (_tabController!.index){
          case 0:
            Get.find<OrderController>().getOrderList(1);
            break;
          case 1:
            Get.find<OrderController>().filterOrder('confirmed',1);
            break;
          case 2:
            Get.find<OrderController>().filterOrder('cooking',1);

            break;
          case 3:
            Get.find<OrderController>().filterOrder('done',1);
            break;
        }
      }


    });

    _disableBatteryOptimization();
  }


  Future _disableBatteryOptimization() async {
    bool isDisabled = await DisableBatteryOptimization.isBatteryOptimizationDisabled ?? false;

    if(!isDisabled) {
      DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
    }
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async{
        _onWillPop(context);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
       floatingActionButton: ResponsiveHelper.isMobile(context) ? const SettingWidget() : null,

        body: ResponsiveHelper.isTab(context) ?
        TabHomeScreen(searchEditController: searchController, tabController: _tabController,) :
        mobileBody(context),
      ),
    );
  }

  Widget mobileBody(BuildContext context) {
    return SafeArea(
        child: GetBuilder<OrderController>(
          builder: (orderController) {
            return !ResponsiveHelper.isMobile(context) ?
            TabHomeScreen(searchEditController: searchController,tabController: _tabController,
            ) : Column(

              children: [

                GetBuilder<OrderController>(
                  builder: (orderController) {
                    return Column(
                      children: [
                        SizedBox(height: 50,
                          child: Image.asset(Images.logoWithName, height: 35),
                        ),
                        searchView( context),

                        Container(
                          height: 50, width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(color: Theme.of(context).cardColor),
                          child: TabBar(
                            controller: _tabController,
                            indicatorColor: Theme.of(context).primaryColor,
                            indicatorWeight: 1,
                            padding: EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeExtraSmall,
                              horizontal: _tabController!.index == 0 || _tabController!.index == 3
                                  ? Dimensions.paddingSizeSmall : 0,
                            ),

                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: _tabController?.index == 0
                                  ? Theme.of(context).primaryColor : _tabController!.index == 1
                                  ? Theme.of(context).colorScheme.primary.withValues(alpha:.15) : _tabController?.index == 2
                                  ? Theme.of(context).primaryColor.withValues(alpha:.15) : Theme.of(context).secondaryHeaderColor.withValues(alpha:.15),
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelColor: _tabController!.index == 0
                                ? Theme.of(context).cardColor : _tabController!.index == 1
                                ? Theme.of(context).colorScheme.primary: _tabController!.index == 2
                                ? Theme.of(context).primaryColor: Theme.of(context).secondaryHeaderColor,
                            unselectedLabelColor: Theme.of(context).textTheme.bodyLarge?.color,

                            unselectedLabelStyle: robotoRegular.copyWith(
                              color: Theme.of(context).hintColor,
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                            labelStyle: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).primaryColor,
                            ),
                            dividerColor: Colors.transparent,

                            tabs: orderController.orderTypeList,
                          ),
                        ),
                      ],
                    );
                  }
                ),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      OrderListWidget(tabController: _tabController!),
                      OrderListWidget(tabController: _tabController!),
                      OrderListWidget(tabController: _tabController!),
                      OrderListWidget(tabController: _tabController!),


                    ],
                  ),
                )
              ],
            );
          }
        ),
      );
  }

  Widget searchView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal : Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      child: SizedBox(
        height: 50,
        child: CustomSearchFieldWidget(

          controller: searchController,
          hint: 'search_hint'.tr,
          prefix: Icons.search,
          suffix: Icons.clear,
          iconPressed: () {
            if(searchController.text.trim().isNotEmpty) {
              Get.find<OrderController>().getOrderList(1);
              searchController.clear();
            }
            FocusScope.of(context).unfocus();
          },
          onChanged: (value){
            if(value.trim().isNotEmpty) {
              _tabController?.index = 0;
              Get.find<OrderController>().searchOrder(value);
            }else{
              FocusScope.of(context).unfocus();
            }
          },
          isFilter: false,
        ),
      ),
    );
  }
}


Future<bool> _onWillPop(BuildContext context) async {
  showAnimatedDialog(context: context,
      barrierDismissible: true,
      animationType: DialogTransitionType.slideFromBottomFade,
      builder: (BuildContext context){
        return LogOutDialogWidget(
          icon: Icons.exit_to_app_rounded, title: 'exit_app'.tr,
          description: 'do_you_want_to_exit_from_this_account'.tr, onTapFalse:() => Navigator.of(context).pop(false),
          onTapTrue:() {
            SystemNavigator.pop();
          },
          onTapTrueText: 'yes'.tr, onTapFalseText: 'no'.tr,
        );
      });
  return true;
}




