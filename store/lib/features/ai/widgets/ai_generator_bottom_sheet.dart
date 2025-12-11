import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/models/config_model.dart';
import 'package:sixam_mart_store/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/util/styles.dart';
import 'package:sixam_mart_store/features/ai/widgets/generate_title_bottom_sheet.dart';
import 'package:sixam_mart_store/features/ai/widgets/image_analyze_bottom_sheet.dart';

class AiGeneratorBottomSheet extends StatelessWidget {
  final List<Language>? languageList;
  final TabController? tabController;
  final List<TextEditingController>? nameControllerList;
  final List<TextEditingController>? descriptionControllerList;
  final TextEditingController? priceController;
  final TextEditingController? discountController;
  final TextEditingController? maxOrderQuantityController;
  final TextEditingController? metaTitleController;
  final TextEditingController? metaDescriptionController;
  final TextEditingController? maxSnippetController;
  final TextEditingController? maxVideoPreviewController;
  const AiGeneratorBottomSheet({super.key, required this.nameControllerList, required this.descriptionControllerList, this.priceController, this.discountController,
    this.maxOrderQuantityController, this.metaTitleController, this.metaDescriptionController, this.maxSnippetController, this.maxVideoPreviewController, this.languageList, this.tabController});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge),
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        Container(
          height: 5, width: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).hintColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
        ),
        const SizedBox(height: 20),

        CustomAssetImageWidget(Images.aiAssistance, height: 70, width: 70),
        const SizedBox(height: 10),

        Text('hi_there'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).hintColor), textAlign: TextAlign.center),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Text('i_am_here_to_help_you'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge), textAlign: TextAlign.center),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          child: Text('ai_assistance_description'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor), textAlign: TextAlign.center),
        ),
        const SizedBox(height: 40),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
          child: CustomButtonWidget(
            buttonText: 'upload_image'.tr,
            icon: Icons.image,
            transparent: true, isBorder: true,
            borderColor: Colors.blue,
            textColor: Theme.of(context).textTheme.bodyLarge?.color,
            iconColor: Colors.blue,
            fontWeight: FontWeight.w400, fontSize: Dimensions.fontSizeDefault,
            onPressed: (){
              Get.bottomSheet(
                isScrollControlled: true, useRootNavigator: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
                ),
                ImageAnalyzeBottomSheet(
                  languageList: languageList,
                  tabController: tabController,
                  nameControllerList: nameControllerList,
                  descriptionControllerList: descriptionControllerList,
                  priceController: priceController,
                  discountController: discountController,
                  maxOrderQuantityController: maxOrderQuantityController,
                  metaTitleController: metaTitleController,
                  metaDescriptionController: metaDescriptionController,
                  maxSnippetController: maxSnippetController,
                  maxVideoPreviewController: maxVideoPreviewController,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
          child: CustomButtonWidget(
            icon: CupertinoIcons.textbox,
            transparent: true, isBorder: true,
            borderColor: Colors.blue,
            textColor: Theme.of(context).textTheme.bodyLarge?.color,
            iconColor: Colors.blue,
            fontWeight: FontWeight.w400, fontSize: Dimensions.fontSizeDefault,
            buttonText: 'generate_food_name'.tr,
            onPressed: (){
              Get.bottomSheet(
                isScrollControlled: true, useRootNavigator: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
                ),
                GenerateTitleBottomSheet(
                  languageList: languageList,
                  tabController: tabController,
                  nameControllerList: nameControllerList,
                ),
              );
            },
          ),
        ),

      ]),
    );
  }
}
