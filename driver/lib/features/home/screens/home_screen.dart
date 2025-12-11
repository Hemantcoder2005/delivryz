import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart_delivery/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_delivery/features/home/widgets/order_count_card_widget.dart';
import 'package:sixam_mart_delivery/features/notification/controllers/notification_controller.dart';
import 'package:sixam_mart_delivery/features/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/color_resources.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/order_shimmer_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/order_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/title_widget.dart';
import 'package:sixam_mart_delivery/features/home/widgets/count_card_widget.dart';
import 'package:sixam_mart_delivery/features/home/widgets/earning_widget.dart';
import 'package:sixam_mart_delivery/features/order/screens/running_order_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late final AppLifecycleListener _listener;
  bool _isNotificationPermissionGranted = true;
  bool _isBatteryOptimizationGranted = true;

  @override
  void initState() {
    super.initState();

    _checkSystemNotification();

    _listener = AppLifecycleListener(
      onStateChange: _onStateChanged,
    );

    _loadData();

    Future.delayed(const Duration(milliseconds: 200), () {
      checkPermission();
    });
  }

  Future<void> _loadData() async {
    Get.find<OrderController>().getIgnoreList();
    Get.find<OrderController>().removeFromIgnoreList();
    await Get.find<ProfileController>().getProfile();
    await Get.find<OrderController>().getCurrentOrders();
    await Get.find<NotificationController>().getNotificationList();
  }

  Future<void> _checkSystemNotification() async {
    if(await Permission.notification.status.isDenied || await Permission.notification.status.isPermanentlyDenied) {
      await Get.find<AuthController>().setNotificationActive(false);
    }
  }

  // Listen to the app lifecycle state changes
  void _onStateChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.resumed:
        checkPermission();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
      case AppLifecycleState.paused:
        break;
    }
  }

  Future<void> checkPermission() async {
    var notificationStatus = await Permission.notification.status;
    var batteryStatus = await Permission.ignoreBatteryOptimizations.status;

    if(notificationStatus.isDenied || notificationStatus.isPermanentlyDenied) {
      setState(() {
        _isNotificationPermissionGranted = false;
        _isBatteryOptimizationGranted = true;
      });

      await Get.find<AuthController>().setNotificationActive(!notificationStatus.isDenied);

    } else if(batteryStatus.isDenied) {
      setState(() {
        _isBatteryOptimizationGranted = false;
        _isNotificationPermissionGranted = true;
      });
    } else {
      setState(() {
        _isNotificationPermissionGranted = true;
        _isBatteryOptimizationGranted = true;
      });
      Get.find<ProfileController>().setBackgroundNotificationActive(true);
    }

    if(batteryStatus.isDenied) {
      Get.find<ProfileController>().setBackgroundNotificationActive(false);
    }
  }

  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.request().isGranted) {
      checkPermission();
      return;
    } else {
      await openAppSettings();
    }

    checkPermission();
  }

  void requestBatteryOptimization() async {
    var status = await Permission.ignoreBatteryOptimizations.status;

    if (status.isGranted) {
      return;
    } else if(status.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    } else {
      openAppSettings();
    }

    checkPermission();
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        surfaceTintColor: Theme.of(context).cardColor,
        shadowColor: Theme.of(context).disabledColor.withValues(alpha: 0.5),
        elevation: 2,
        leading: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Image.asset(Images.logo, height: 30, width: 30),
        ),
        titleSpacing: 0,
        title: Text(AppConstants.appName, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoMedium.copyWith(
          color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeDefault,
        )),
        actions: [
          IconButton(
            icon: GetBuilder<NotificationController>(builder: (notificationController) {
              return Stack(children: [

                Icon(Icons.notifications, size: 25, color: Theme.of(context).textTheme.bodyLarge!.color),

                notificationController.hasNotification ? Positioned(top: 0, right: 0, child: Container(
                  height: 10, width: 10, decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error, shape: BoxShape.circle,
                  border: Border.all(width: 1, color: Theme.of(context).cardColor),
                ),
                )) : const SizedBox(),

              ]);
            }),
            onPressed: () => Get.toNamed(RouteHelper.getNotificationRoute()),
          ),

          const SizedBox(width: Dimensions.paddingSizeSmall),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          return await _loadData();
        },
        child: Column(children: [

          if(!_isNotificationPermissionGranted)
            permissionWarning(isBatteryPermission: false, onTap: requestNotificationPermission, closeOnTap: () {
              setState(() {
                _isNotificationPermissionGranted = true;
              });
            }),

          if(!_isBatteryOptimizationGranted)
            permissionWarning(isBatteryPermission: true, onTap: requestBatteryOptimization, closeOnTap: () {
              setState(() {
                _isBatteryOptimizationGranted = true;
              });
            }),

          Expanded(
            child: SingleChildScrollView(
              // padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
              child: GetBuilder<ProfileController>(builder: (profileController) {

                return Column(children: [

                  GetBuilder<OrderController>(builder: (orderController) {

                    bool hasActiveOrder = orderController.currentOrderList == null || orderController.currentOrderList!.isNotEmpty;
                    bool hasMoreOrder = orderController.currentOrderList != null && orderController.currentOrderList!.length > 1;

                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                      child: Column(children: [
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        hasActiveOrder ? TitleWidget(
                          title: 'active_order'.tr, showOrderCount: true, orderCount: orderController.currentOrderList?.length ?? 0,
                            onTap: hasMoreOrder ? () {
                            Get.toNamed(RouteHelper.getRunningOrderRoute(), arguments: const RunningOrderScreen());
                          } : null,
                        ) : const SizedBox(),
                        SizedBox(height: hasActiveOrder ? Dimensions.paddingSizeExtraSmall : 0),

                        orderController.currentOrderList == null ? OrderShimmerWidget(
                          isEnabled: orderController.currentOrderList == null,
                        ) : orderController.currentOrderList!.isNotEmpty ? OrderWidget(
                          orderModel: orderController.currentOrderList![0], isRunningOrder: true, orderIndex: 0, cardWidth: context.width * 0.9,
                        )/*SizedBox(
                          height: 200,
                          child: ListView.builder(
                              itemCount: orderController.currentOrderList!.length,
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 3),
                              itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                              child: OrderWidget(
                                orderModel: orderController.currentOrderList![index], isRunningOrder: true, orderIndex: index, cardWidth: context.width * 0.9,
                              ),
                            );
                          }),
                        )*/ : const SizedBox(),
                        SizedBox(height: hasActiveOrder ? Dimensions.paddingSizeDefault : 0),

                      ]),
                    );
                  }),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                    child: Column(children: [
                      (profileController.profileModel != null && profileController.profileModel!.earnings == 1) ? Column(children: [

                        TitleWidget(title: 'earnings'.tr),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Container(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            color: Theme.of(context).primaryColor,
                          ),
                          child: Column(children: [

                            Row(mainAxisAlignment: MainAxisAlignment.start, children: [

                              const SizedBox(width: Dimensions.paddingSizeSmall),
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, left: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall),
                                child: Image.asset(Images.wallet, width: 40, height: 40),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeLarge),

                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                Text(
                                  'balance'.tr,
                                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor.withValues(alpha: 0.9)),
                                ),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                profileController.profileModel != null ? Text(
                                  PriceConverterHelper.convertPrice(profileController.profileModel!.balance),
                                  style: robotoBold.copyWith(fontSize: 24, color: Theme.of(context).cardColor),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ) : Container(height: 30, width: 60, color: Colors.white),

                              ]),
                            ]),
                            const SizedBox(height: Dimensions.paddingSizeLarge),
                            Row(children: [

                              EarningWidget(
                                title: 'today'.tr,
                                amount: profileController.profileModel?.todaysEarning,
                              ),
                              Container(height: 30, width: 1, color: Theme.of(context).cardColor.withValues(alpha: 0.8)),

                              EarningWidget(
                                title: 'this_week'.tr,
                                amount: profileController.profileModel?.thisWeekEarning,
                              ),
                              Container(height: 30, width: 1, color: Theme.of(context).cardColor.withValues(alpha: 0.8)),

                              EarningWidget(
                                title: 'this_month'.tr,
                                amount: profileController.profileModel?.thisMonthEarning,
                              ),

                            ]),

                          ]),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                      ]) : const SizedBox(),

                      TitleWidget(title: 'orders'.tr),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      (profileController.profileModel != null && profileController.profileModel!.earnings == 1) ? Row(children: [

                        OrderCountCardWidget(
                          title: 'todays_orders'.tr,
                          value: profileController.profileModel?.todaysOrderCount.toString(),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),

                        OrderCountCardWidget(
                          title: 'this_week_orders'.tr,
                          value: profileController.profileModel?.thisWeekOrderCount.toString(),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),

                        OrderCountCardWidget(
                          title: 'total_orders'.tr,
                          value: profileController.profileModel?.orderCount.toString(),
                        ),

                      ]) : Column(children: [

                        Row(children: [

                          Expanded(child: CountCardWidget(
                            title: 'todays_orders'.tr, backgroundColor: const Color(0xffE5EAFF), height: 180,
                            value: profileController.profileModel?.todaysOrderCount.toString(),
                          )),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          Expanded(child: CountCardWidget(
                            title: 'this_week_orders'.tr, backgroundColor: const Color(0xffE84E50).withValues(alpha: 0.2), height: 180,
                            value: profileController.profileModel?.thisWeekOrderCount.toString(),
                          )),

                        ]),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        CountCardWidget(
                          title: 'total_orders'.tr, backgroundColor: const Color(0xffE1FFD8), height: 140,
                          value: profileController.profileModel?.orderCount.toString(),
                        ),

                      ]),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      profileController.profileModel != null ? profileController.profileModel!.cashInHands! > 0 ? Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          border: Border.all(color: Theme.of(context).disabledColor, width: 0.2),
                          boxShadow: [BoxShadow(color: Get.isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), blurRadius: 20, spreadRadius: 0, offset: const Offset(0, 5))],

                        ),
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeLarge),
                        child: Column(children: [

                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(Images.payMoney, height: 40,),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          Text(
                            PriceConverterHelper.convertPrice(profileController.profileModel!.cashInHands),
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: 'cash_in_your_hand'.tr, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.8))),

                                if((profileController.profileModel!.dmMaxMyAccount != null) && (profileController.profileModel!.dmMaxMyAccount! > 0) && (profileController.profileModel!.cashInHands! > profileController.profileModel!.dmMaxMyAccount!))
                                  TextSpan(text: ' (${'limit_exceeded'.tr})', style: robotoRegular.copyWith(color: ColorResources.red, fontSize: Dimensions.fontSizeSmall - 2)),
                              ],
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          CustomButtonWidget(
                            width: 90, height: 40,
                            isBold: false,
                            fontSize: Dimensions.fontSizeDefault,
                            buttonText: 'pay_now'.tr,
                            backgroundColor: Theme.of(context).primaryColor,
                            onPressed: () => Get.toNamed(RouteHelper.getMyAccountRoute()),
                          ),

                        ]),
                      ) : const SizedBox() : Shimmer(
                        duration: const Duration(seconds: 2),
                        enabled: true,
                        child: Container(
                          height: 85, width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            color: Theme.of(context).shadowColor,
                          ),
                        ),
                      ),
                    ]),
                  ),



                ]);
              }),
            ),
          ),
        ]),
      ),
    );
  }

  Widget permissionWarning({required bool isBatteryPermission, required Function() onTap, required Function() closeOnTap}) {
    return GetPlatform.isAndroid ? Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.7),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Row(children: [

            if(isBatteryPermission)
              Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Image.asset(Images.allertIcon, height: 20, width: 20),
              ),

            Expanded(
              child: Row(children: [
                Flexible(
                  child: Text(
                    isBatteryPermission ? 'for_better_performance_allow_notification_to_run_in_background'.tr
                        : 'notification_is_disabled_please_allow_notification'.tr,
                    maxLines: 2, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.white),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                const Icon(Icons.arrow_circle_right_rounded, color: Colors.white, size: 24,),
              ]),
            ),

            // const SizedBox(width: 20),
          ]),
        ),
      ),
    ) : const SizedBox();
  }
}
