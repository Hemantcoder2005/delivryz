import 'package:sixam_mart_store/common/widgets/custom_ink_well_widget.dart';
import 'package:sixam_mart_store/features/order/controllers/order_controller.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/styles.dart';
import 'package:flutter/material.dart';

class OrderButtonWidget extends StatelessWidget {
  final String title;
  final int index;
  final OrderController orderController;
  final bool fromHistory;
  const OrderButtonWidget({super.key, required this.title, required this.index, required this.orderController, required this.fromHistory});

  @override
  Widget build(BuildContext context) {
    int selectedIndex;
    int length = 0;
    int titleLength = 0;
    if(fromHistory) {
      selectedIndex = orderController.historyIndex;
      titleLength = orderController.statusList.length;
      length = 0;
    }else {
      selectedIndex = orderController.orderIndex;
      titleLength = orderController.runningOrders!.length;
      length = orderController.runningOrders![index].orderList.length;
    }
    bool isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
      child: CustomInkWellWidget(
        radius: Dimensions.radiusDefault,
        onTap: () => fromHistory ? orderController.setHistoryIndex(index) : orderController.setOrderIndex(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(color: Theme.of(context).disabledColor, width: 0.5),
            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
          ),
          alignment: Alignment.center,
          child: Row(
            children: [
              Text(
                title,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: isSelected ? Theme.of(context).cardColor : Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),

              !fromHistory ? Container(
                margin: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: 2),
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                //   color: isSelected ? Theme.of(context).cardColor.withValues(alpha: 0.2) : Theme.of(context).cardColor.withValues(alpha: 0.4),
                // ),
                child: Text(
                  '($length)',
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: isSelected ? Theme.of(context).cardColor : Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
              ) : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
