import 'package:efood_kitchen/features/order/controllers/order_controller.dart';
import 'package:efood_kitchen/features/order/domain/models/order_model.dart';
import 'package:efood_kitchen/helper/responsive_helper.dart';
import 'package:efood_kitchen/util/dimensions.dart';
import 'package:efood_kitchen/common/widgets/no_data_widget.dart';
import 'package:efood_kitchen/features/order/widgets/order_shimmer_widget.dart';
import 'package:efood_kitchen/features/home/widgets/order_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class OrderListWidget extends StatelessWidget {
  final TabController tabController;

  const OrderListWidget({Key? key, required this.tabController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = (Get.height / Get.width) > 1 && (Get.height / Get.width) < 1.7;
    return RefreshIndicator(
      color: Theme.of(context).cardColor,
      backgroundColor: Theme.of(context).primaryColor,
      onRefresh: () async {
        tabController.index = 0;
        await Get.find<OrderController>().getOrderList(1);
      },
      child: GetBuilder<OrderController>(
        builder: (orderController) {
          List<Orders>? orderList = orderController.orderList ;

          return Padding(
            padding: const EdgeInsets.only(
              right: Dimensions.paddingSizeDefault,
              top: Dimensions.paddingSizeDefault,
              left: Dimensions.paddingSizeDefault,
            ),
            child: Column(children: [

              orderList != null ? orderList.isNotEmpty ?
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: orderController.scrollController,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ResponsiveHelper.isSmallTab() || isMobile ? 3 :  !ResponsiveHelper.isTab(context)  ? 2 : 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: ResponsiveHelper.isSmallTab() ? 0.75 : ResponsiveHelper.isTab(context) ? 0.85 : 1/1.2 ,
                  ),
                  padding: const EdgeInsets.all(0),
                  itemCount: orderList.length,
                  itemBuilder: (context, index) {

                    return OrderCardWidget(order: orderList[index]);
                  },
                ),
              )
                : const NoDataWidget() : const Expanded(child: OrderShimmerWidget()),


              orderController.isLoading && orderController.orderList != null ? Center(child: Padding(
                padding: const EdgeInsets.all(Dimensions.iconSize),
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
              )) : const SizedBox.shrink(),

            ]),
          );
        },
      ),
    );
  }
}
//order: orderList[index]