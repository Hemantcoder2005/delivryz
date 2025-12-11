import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_ink_well_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_store/features/coupon/controllers/coupon_controller.dart';
import 'package:sixam_mart_store/features/coupon/domain/models/coupon_body_model.dart';
import 'package:sixam_mart_store/helper/date_converter_helper.dart';
import 'package:sixam_mart_store/helper/price_converter_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/util/styles.dart';
import 'package:sixam_mart_store/common/widgets/confirmation_dialog_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_loader_widget.dart';
import 'package:sixam_mart_store/features/coupon/screens/add_coupon_screen.dart';

class CouponCardDialogueWidget extends StatelessWidget {
  final CouponBodyModel couponBody;
  final int index;
  const CouponCardDialogueWidget({super.key, required this.couponBody, required this.index});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault,
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,mainAxisSize: MainAxisSize.min, children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(),

                          Container(
                            height: 5, width: 70,
                            decoration: BoxDecoration(
                              color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            ),
                          ),

                          InkWell(
                            onTap: () => Get.back(),
                            child: Icon(Icons.close, color: Theme.of(context).hintColor, size: 20),
                          ),
                        ],
                      ),


                      Padding(
                        padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                          Expanded(
                            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                              SizedBox(
                                height: 50, width: 50,
                                child: Image.asset(couponBody.discountType == 'percent' ? Images.fire : Images.cashIcon),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),
                              Text(
                                '${couponBody.title}',
                                style: robotoMedium.copyWith(fontSize: 20), textDirection: TextDirection.ltr,
                              ),
                              Text(
                                '${DateConverterHelper.stringToLocalDateOnly(couponBody.startDate!)} - ${DateConverterHelper.stringToLocalDateOnly(couponBody.startDate!)}',
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.6)),
                              ),
                            ]),
                          ),

                          // const Spacer(),

                          GetBuilder<CouponController>(builder: (couponController) {
                            return Padding(
                              padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                                      border: Border.all(color: Theme.of(context).disabledColor, width: 0.2),
                                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                    child: Row(
                                      children: [
                                        Text('status'.tr, style: robotoMedium),

                                        Transform.scale(
                                          scale: 0.7,
                                          child: CupertinoSwitch(
                                            activeTrackColor: Theme.of(context).primaryColor,
                                            value: couponController.coupons![index].status == 1 ? true : false,
                                            onChanged: (bool status){
                                              couponController.changeStatus(couponController.coupons![index].id, status).then((success) {
                                                if(success){
                                                  couponController.getCouponList();
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeSmall),

                                  Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                                      border: Border.all(color: Theme.of(context).disabledColor, width: 0.2),
                                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                    ),
                                    child: CustomInkWellWidget(
                                      onTap: () {
                                        Get.back();
                                        Get.dialog(ConfirmationDialogWidget(
                                          icon: Images.warning, title: 'are_you_sure_to_delete'.tr, description: 'you_want_to_delete_this_coupon'.tr,
                                          onYesPressed: () {
                                            couponController.deleteCoupon(couponBody.id);
                                          },
                                        ), barrierDismissible: false);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall-3),
                                        child: Icon(Icons.delete_forever, color: Colors.red),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          }),

                        ]),
                      ),

                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                                border: Border.all(color: Theme.of(context).disabledColor, width: 0.2),
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              ),
                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                              child: Column(children: [
                                Text('discount'.tr, style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5))),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                Text('${'${couponBody.couponType == 'free_delivery' ? 'free_delivery'.tr : couponBody.discountType != 'percent' ?
                                PriceConverterHelper.convertPrice(double.parse(couponBody.discount.toString())) :
                                couponBody.discount}'} ${couponBody.couponType == 'free_delivery' ? '' : couponBody.discountType == 'percent' ? '% ' : ''}'
                                    '${couponBody.couponType == 'free_delivery' ? '' : 'off'.tr}',
                                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall), textDirection: TextDirection.ltr,
                                ),
                              ]),
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                                border: Border.all(color: Theme.of(context).disabledColor, width: 0.2),
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              ),
                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(children: [
                                      Text('coupon_code'.tr, style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5))),
                                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                      Text(
                                        '${couponBody.code}',
                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall), textDirection: TextDirection.ltr,
                                      ),
                                    ]),
                                  ),

                                  IconButton(
                                    onPressed: (){
                                      Clipboard.setData(ClipboardData(text: couponBody.code!)).then((value) {
                                        showCustomSnackBar('coupon_code_copied'.tr);
                                      });
                                    },
                                    icon: Icon(Icons.copy, color: Colors.blue, size: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          border: Border.all(color: Theme.of(context).disabledColor, width: 0.5),
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: Column(children: [
                          section('total_user'.tr, '${couponBody.totalUses??0}'),
                          section('limit_for_same_user'.tr, '${couponBody.limit??0}'),
                          section('maximum_discount'.tr, PriceConverterHelper.convertPrice(double.parse(couponBody.maxDiscount.toString()))),
                          section('minimum_order_amount'.tr, PriceConverterHelper.convertPrice(double.parse(couponBody.minPurchase.toString())), showDivider: false),
                        ]),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                    ]),
                  ),
                ],
              ),
            ),

            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, -2))]
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: GetBuilder<CouponController>(
                  builder: (couponController) {
                    return Row(children: [
                      Expanded(
                        child: CustomButtonWidget(
                          onPressed: () {
                            Get.back();
                          },
                          buttonText: 'cancel'.tr,
                          color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                          textColor: Theme.of(context).textTheme.bodyLarge!.color!,
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeLarge),

                      Expanded(
                        child: CustomButtonWidget(
                          onPressed: () {
                            Get.back();
                            Get.dialog(const CustomLoaderWidget());
                            couponController.getCouponDetails(couponController.coupons![index].id!).then((couponDetails) {
                              Get.back();
                              if(couponDetails != null) {
                                Get.to(() => AddCouponScreen(coupon: couponDetails));
                              }
                            });
                          },
                          buttonText: 'edit'.tr,
                        ),
                      ),
                    ]);
                  }
              ),
            )
          ],
        ),
      ),
    );
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge)),
      insetPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      alignment: Alignment.center,
      backgroundColor: Colors.transparent,
      child: SizedBox(
        width: 500,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Container(
            width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.52,
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
            decoration: BoxDecoration(
              color: Get.isDarkMode ? Colors.black87 : Colors.transparent,
              image: DecorationImage(image: const AssetImage(Images.couponDetails), fit: BoxFit.fitWidth,
                  colorFilter: Get.isDarkMode ? ColorFilter.mode(Colors.black.withValues(alpha: 0.2), BlendMode.dstATop) : null,
              ),
            ),
            child: Stack(
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start,mainAxisSize: MainAxisSize.min, children: [
                  Row(children: [

                    SizedBox(
                      height: 50, width: 50,
                      child: Stack(children: [
                        Image.asset(Images.couponVertical, color: Theme.of(context).primaryColor),
                        Positioned(
                          top: 15, left: 15,
                          child: Text(couponBody.couponType == 'free_delivery' ? '' : couponBody.discountType == 'percent' ? ' %' : ' \$',
                            style: robotoBold.copyWith(fontSize: 18, color: Theme.of(context).cardColor),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${'${couponBody.couponType == 'free_delivery' ? 'free_delivery'.tr : couponBody.discountType != 'percent' ?
                      PriceConverterHelper.convertPrice(double.parse(couponBody.discount.toString())) :
                      couponBody.discount}'} ${couponBody.couponType == 'free_delivery' ? '' : couponBody.discountType == 'percent' ? ' %' : ''}'
                          '${couponBody.couponType == 'free_delivery' ? '' : 'off'.tr}',
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                      ),
                      Text('${couponBody.code}', style: robotoMedium),
                    ]),
                    const Spacer(),

                    GetBuilder<CouponController>(
                      builder: (couponController) {
                        return Transform.scale(
                          scale: 0.7,
                          child: CupertinoSwitch(
                            activeTrackColor: Theme.of(context).primaryColor,
                            inactiveTrackColor: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                            value: couponController.coupons![index].status == 1 ? true : false,
                            onChanged: (bool status){
                              couponController.changeStatus(couponController.coupons![index].id, status).then((success) {
                                if(success){
                                  couponController.getCouponList();
                                }
                              });
                            },
                          ),
                        );
                      }
                    ),

                  ]),

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Text('- ${'start_date'.tr} : ${couponBody.startDate!}',
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Text('- ${'expire_date'.tr} : ${couponBody.expireDate!}',
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Text('- ${'total_user'.tr} : ${couponBody.totalUses.toString()}',
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Text('- ${'min_purchase'.tr} : ${couponBody.minPurchase.toString()}',
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Text('- ${'limit'.tr} : ${couponBody.limit.toString()}',
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Text('- ${'coupon_type'.tr} : ${couponBody.couponType!.tr}',
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                ]),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: GetBuilder<CouponController>(
                      builder: (couponController) {
                        return Row(mainAxisSize: MainAxisSize.min, children: [
                          OutlinedButton(
                            style: ButtonStyle(
                              side: WidgetStateProperty.all(const BorderSide(
                                  color: Colors.blue,
                                  width: 1.0,
                                  style: BorderStyle.solid)),
                            ),
                            onPressed: (){
                              Get.back();
                              Get.dialog(const CustomLoaderWidget());
                              couponController.getCouponDetails(couponController.coupons![index].id!).then((couponDetails) {
                                Get.back();
                                if(couponDetails != null) {
                                  Get.to(() => AddCouponScreen(coupon: couponDetails));
                                }
                              });
                            },
                            child: const Icon(Icons.edit, color: Colors.blue),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeExtraLarge),

                          OutlinedButton(
                            style: ButtonStyle(
                              side: WidgetStateProperty.all(const BorderSide(
                                  color: Colors.red,
                                  width: 1.0,
                                  style: BorderStyle.solid)),
                            ),
                            onPressed: (){
                              Get.back();
                              Get.dialog(ConfirmationDialogWidget(
                                icon: Images.warning, title: 'are_you_sure_to_delete'.tr, description: 'you_want_to_delete_this_coupon'.tr,
                                onYesPressed: () {
                                  couponController.deleteCoupon(couponBody.id);
                                },
                              ), barrierDismissible: false);
                            },
                            child: const Icon(Icons.delete_outline, color: Colors.red),
                          ),
                        ]);
                      }
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget section(String title, String value, {bool showDivider = true}) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

          Text(
            title,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(Get.context!).hintColor),
          ),

          Text(
            value,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
          ),
        ]),
      ),
      if(showDivider)
        const Divider(height: 5),
    ]);
  }
}
