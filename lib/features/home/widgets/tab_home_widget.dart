import 'package:efood_kitchen/features/order/controllers/order_controller.dart';
import 'package:efood_kitchen/features/order/domain/models/order_model.dart';
import 'package:efood_kitchen/helper/responsive_helper.dart';
import 'package:efood_kitchen/util/dimensions.dart';
import 'package:efood_kitchen/common/widgets/no_data_widget.dart';
import 'package:efood_kitchen/features/order/widgets/order_shimmer_widget.dart';
import 'package:efood_kitchen/features/home/widgets/order_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class TabHomeView extends StatefulWidget {
  const TabHomeView({Key? key}) : super(key: key);

  @override
  State<TabHomeView> createState() => _TabHomeViewState();
}

class _TabHomeViewState extends State<TabHomeView> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(
      builder: (orderController) {
        List<Orders>? orderList = orderController.orderList;

        return Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Stack(
            children: [
              Column(children: [

                orderList != null ? orderList.isNotEmpty ?
                GridView.builder(
                  controller: orderController.scrollController,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ResponsiveHelper.isSmallTab() ? 2 : 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio:  MediaQuery.of(context).size.width>1200? 1/.77 : 1/1.1,
                  ),
                  padding: const EdgeInsets.all(0),
                  itemCount: orderList.length,
                  itemBuilder: (context, index) {
                    return OrderCardWidget(order: orderList[index]);
                  },
                )
                  : const NoDataWidget() : const OrderShimmerWidget(),
                orderController.isLoading && orderList != null ? Center(child: Padding(
                  padding: const EdgeInsets.all(Dimensions.iconSize),
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
                )) : const SizedBox.shrink(),

              ]),

            ],
          ),
        );
      },
    );
  }
}
//order: orderList[index]