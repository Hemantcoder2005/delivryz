import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:sixam_mart_delivery/features/my_account/controllers/my_account_controller.dart';
import 'package:sixam_mart_delivery/features/my_account/widgets/earning_history_bottom_sheet.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/helper/date_converter_helper.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class MyEarningScreen extends StatefulWidget {
  const MyEarningScreen({super.key});

  @override
  State<MyEarningScreen> createState() => _MyEarningScreenState();
}

class _MyEarningScreenState extends State<MyEarningScreen> {

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Get.find<MyAccountController>().resetEarningFilter(isUpdate: false);
    Get.find<MyAccountController>().setOffset(1);

    Get.find<MyAccountController>().getEarningReport(
      offset: Get.find<MyAccountController>().offset.toString(),
      startDate: Get.find<MyAccountController>().from, endDate: Get.find<MyAccountController>().to,
      type: 'all_types_earning',
    );

    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent
          && Get.find<MyAccountController>().earningList != null
          && !Get.find<MyAccountController>().isLoading) {
        int pageSize = (Get.find<MyAccountController>().pageSize! / 10).ceil();
        if (Get.find<MyAccountController>().offset < pageSize) {
          Get.find<MyAccountController>().setOffset(Get.find<MyAccountController>().offset+1);
          debugPrint('end of the page');
          Get.find<MyAccountController>().showBottomLoader();
          Get.find<MyAccountController>().getEarningReport(
            offset: Get.find<MyAccountController>().offset.toString(),
            startDate: Get.find<MyAccountController>().from, endDate: Get.find<MyAccountController>().to,
            type: Get.find<MyAccountController>().selectedEarningType, fromFilter: Get.find<MyAccountController>().isFiltered,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyAccountController>(builder: (myAccountController) {
      return Scaffold(
        appBar: CustomAppBarWidget(
          title: 'my_earning'.tr,
          actionWidget: Row(children: [

            InkWell(
              onTap: () {
                myAccountController.downloadEarningInvoice(dmId: Get.find<ProfileController>().profileModel!.id!);
              },
              child: Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: !myAccountController.downloadLoading! ? Icon(Icons.download, size: 20,
                  color: Theme.of(context).cardColor,
                ) : const SizedBox(
                  width: 20, height: 20,
                  child: Padding(
                    padding: EdgeInsets.all(3),
                    child: Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall + 2),

            InkWell(
              onTap: () {
                Get.toNamed(RouteHelper.getMyEarningFilterRoute());
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    child: Icon(Icons.filter_list_sharp, size: 20,
                      color: Theme.of(context).cardColor,
                    ),
                  ),

                  if(myAccountController.isFiltered)
                    Positioned(
                      top: -4, right: -4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          height: 10, width: 10,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

          ]),
        ),

        body: GetBuilder<MyAccountController>(builder: (myAccountController) {
          return myAccountController.earningList != null ? myAccountController.earningList!.isNotEmpty ? SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              SizedBox(
                height: 90,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [

                    Container(
                      width: 170,
                      margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(
                        color: const Color(0xff313F38).withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: Column(children: [
                        Text(PriceConverterHelper.convertPrice((myAccountController.earningReportModel?.totalDeliveryCharge ?? 0) + (myAccountController.earningReportModel?.totalDmTips ?? 0)),
                            style: robotoBold.copyWith(color: Get.isDarkMode ? Theme.of(context).primaryColor : const Color(0xff313F38), fontSize: Dimensions.fontSizeExtraLarge)),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall - 2),

                        Text('total_earning'.tr, style: robotoMedium.copyWith(color: Theme.of(context).hintColor)),
                      ]),
                    ),

                    Container(
                      width: 170,
                      margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(
                        color: const Color(0xffFF7E0D).withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: Column(children: [
                        Text(PriceConverterHelper.convertPrice(myAccountController.earningReportModel?.totalDeliveryCharge), style: robotoBold.copyWith(color: const Color(0xffFF7E0D), fontSize: Dimensions.fontSizeExtraLarge)),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall - 2),

                        Text('delivery_fee_earned'.tr, style: robotoMedium.copyWith(color: Theme.of(context).hintColor)),
                      ]),
                    ),

                    Container(
                      width: 170,
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(
                        color: const Color(0xff006FBD).withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: Column(children: [
                        Text(PriceConverterHelper.convertPrice(myAccountController.earningReportModel?.totalDmTips), style: robotoBold.copyWith(color: const Color(0xff006FBD), fontSize: Dimensions.fontSizeExtraLarge)),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall - 2),

                        Text('delivery_tips_earned'.tr, style: robotoMedium.copyWith(color: Theme.of(context).hintColor)),
                      ]),
                    )

                  ]),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('earning_statement'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).hintColor)),
                Text('${myAccountController.pageSize ?? 0} ${'result_found'.tr}', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).hintColor)),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              CustomCard(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(children: [
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: myAccountController.earningList!.length,
                    itemBuilder: (context, index) {

                      final earning = myAccountController.earningList![index];
                      double orderWiseTotalEarning = (earning.dmTips ?? 0) + (earning.originalDeliveryCharge ?? 0);
                      double deliveryFee = earning.originalDeliveryCharge ?? 0;
                      double deliveryTip = earning.dmTips ?? 0;

                      return InkWell(
                        onTap: () {
                          showCustomBottomSheet(child: EarningHistoryBottomSheet(data: earning));
                        },
                        child: Column(children: [
                          Container(
                            margin: EdgeInsets.only(bottom: index == myAccountController.earningList!.length - 1 ? 0 : Dimensions.paddingSizeSmall),
                            child: Row(children: [

                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(
                                  PriceConverterHelper.convertPrice(
                                  myAccountController.selectedEarningType == 'all_types_earning' ? orderWiseTotalEarning
                                    : myAccountController.selectedEarningType == 'delivery_fee' ? deliveryFee : deliveryTip,
                                  ),
                                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                                ),

                                Text('${'order'.tr} #${earning.order?.id}', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.6), fontSize: Dimensions.fontSizeSmall)),

                                (myAccountController.selectedEarningType == 'delivery_fee' && myAccountController.selectedEarningType != 'all_types_earning') ? Text(
                                  'delivery_fee'.tr,
                                  style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                                ) : (myAccountController.selectedEarningType == 'delivery_tips' && myAccountController.selectedEarningType != 'all_types_earning') ? Text(
                                  'delivery_tips'.tr,
                                  style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                                ) : Row(
                                  children: [
                                    earning.originalDeliveryCharge != 0 ? Text(
                                      'delivery_fee'.tr,
                                      style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                                    ) : const SizedBox(),

                                    earning.originalDeliveryCharge != 0 && earning.dmTips != 0 ? Text(', ', style: robotoRegular.copyWith(color: Theme.of(context).hintColor)) : const SizedBox(),

                                    earning.dmTips != 0 ? Text(
                                      'delivery_tips'.tr,
                                      style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                                    ) : const SizedBox(),
                                  ],
                                ),
                              ]),
                              const Spacer(),

                              Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
                                Text(DateConverterHelper.utcToDateTime(earning.createAt!), style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
                                const SizedBox(height: Dimensions.paddingSizeDefault),

                                Container(
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).hintColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  ),
                                  child: Icon(Icons.arrow_forward_ios, size: 12,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                              ]),

                            ]),
                          ),

                          index != myAccountController.earningList!.length - 1 ? Padding(
                            padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeDefault),
                            child: DottedBorder(
                              options: RoundedRectDottedBorderOptions(
                                color: Theme.of(context).hintColor.withValues(alpha: 0.2), strokeWidth: 1, dashPattern: const [4, 8],
                                padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                                radius: Radius.zero,
                              ),
                              child: Container(),
                            ),
                          ) : const SizedBox(),
                        ]),
                      );
                    },
                  ),
                ]),
              ),

            ]),
          ) : Center(
            child: Text('no_earning_found'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
          ) : const Center(child: CircularProgressIndicator());
        }),
      );
    });
  }
}
