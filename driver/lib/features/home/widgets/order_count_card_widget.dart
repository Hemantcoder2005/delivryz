import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class OrderCountCardWidget extends StatelessWidget {
  final String title;
  final String? value;
  const OrderCountCardWidget({super.key, required this.title, this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomCard(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge, vertical: Dimensions.paddingSizeLarge),
        child: Column(children: [

          value != null ? Text(
            value!, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).textTheme.bodyLarge?.color), textAlign: TextAlign.center,
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ) : Shimmer(
            duration: const Duration(seconds: 2),
            color: Theme.of(context).shadowColor,
            child: Container(height: 15, width: 15, decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(5))),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          Text(
            title,
            style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
            textAlign: TextAlign.center,
          ),

        ]),
      ),
    );
  }
}
