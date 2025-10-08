import 'package:efood_kitchen/features/order/controllers/order_controller.dart';
import 'package:efood_kitchen/helper/responsive_helper.dart';
import 'package:efood_kitchen/util/dimensions.dart';
import 'package:efood_kitchen/common/widgets/custom_search_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchWidget extends StatelessWidget {
  final TextEditingController searchEditController;
  final TabController? tabController;
  const SearchWidget({Key? key, required this.searchEditController, required this.tabController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal : Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      child: SizedBox(
        height: ResponsiveHelper.isSmallTab() ? 40 : 50,
        child: CustomSearchFieldWidget(
          controller: searchEditController,
          hint: 'search_hint'.tr,
          prefix: Icons.search,
          suffix: Icons.clear,
          iconPressed: () {
            if(searchEditController.text.trim().isNotEmpty) {
              Get.find<OrderController>().getOrderList(1);
              searchEditController.clear();
            }
            FocusScope.of(context).unfocus();
          },
          onChanged: (value){
            if(value.trim().isNotEmpty) {
              tabController?.index = 0;
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
