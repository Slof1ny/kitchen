import 'package:efood_kitchen/common/widgets/custom_divider_widget.dart';
import 'package:efood_kitchen/common/widgets/custom_loader_widget.dart';
import 'package:efood_kitchen/features/order/controllers/order_controller.dart';
import 'package:efood_kitchen/features/home/widgets/status_change_custom_button.dart';
import 'package:efood_kitchen/features/order/widgets/calculate_amount_widget.dart';
import 'package:efood_kitchen/features/order/widgets/ordered_product_list_widget.dart';
import 'package:efood_kitchen/util/dimensions.dart';
import 'package:efood_kitchen/util/images.dart';
import 'package:efood_kitchen/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:get/get.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailsScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    Get.find<OrderController>().getOrderDetails(widget.orderId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: RefreshIndicator(
        color: Theme.of(context).cardColor,
        backgroundColor: Theme.of(context).primaryColor,
        onRefresh: () async {
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              floating: true,
              elevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false,
              backgroundColor: Theme.of(context).highlightColor,
              title: Image.asset(Images.logoWithName, height: 35),
            ),

            // Search Button
            SliverPersistentHeader(
                pinned: true,
                delegate: _SliverDelegate(
                  height: 70,
                    child: GetBuilder<OrderController>(
                      builder: (orderDetails) {
                        return  Column(
                          children: [
                            ClipPath(
                              clipper: MultipleRoundedCurveClipper(),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).hintColor.withValues(alpha:.125),
                                ),
                                height: 10,
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                ),

                                alignment: Alignment.center,
                                child: InkWell(
                                  onTap: () => Get.back(),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const SizedBox(),
                                          orderDetails.isDetails? const SizedBox() :
                                          Column(mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text('${'order'.tr}# ${orderDetails.orderDetails.order.id.toString()}',
                                                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),),
                                              Row(
                                                children: [
                                                  orderDetails.orderDetails.order.table != null ?
                                                  Text('${'table'.tr} ${orderDetails.orderDetails.order.table!.number!} | ',
                                                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)):const SizedBox(),
                                                  orderDetails.orderDetails.order.numberOfPeople != 0?
                                                  Text('${orderDetails.orderDetails.order.numberOfPeople} ${'people'.tr}'):const SizedBox(),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const Icon(Icons.clear),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    ))),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                child: GetBuilder<OrderController>(
                  builder: (orderDetailsController) {

                    return orderDetailsController.isDetails?
                    const CustomLoaderWidget():
                    Column(children: [
                      OrderedProductListWidget(orderController: orderDetailsController),


                      Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text("${'note'.tr}: ", style: robotoBold),
                            Expanded(child: Text(orderDetailsController.orderDetails.order.orderNote, maxLines: 5,overflow: TextOverflow.clip,)),
                          ],
                        ),
                      ),
                      const CustomDividerWidget(),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      CalculateAmountWidget(orderController: orderDetailsController),


                    ],);
                  }
                ),
              ),
            )
          ],
        ),
      ),

      bottomNavigationBar: GetBuilder<OrderController>(
        builder: (orderDetails) {
          return StatusChangeCustomButton( orderId: widget.orderId,
            orderStatus: orderDetails.orderDetails.order.orderStatus);
        }
      ),
    );
  }
}


class _SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;
  _SliverDelegate({required this.child , required this.height});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(_SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height || oldDelegate.minExtent != height || child != oldDelegate.child;
  }
}
