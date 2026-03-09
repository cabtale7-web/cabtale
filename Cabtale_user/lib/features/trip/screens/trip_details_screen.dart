import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/loader_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/swipable_button_widget/slider_button_widget.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/parcel_details_widget.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/rider_info.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/trip_details.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/trip_item_view.dart';
import 'package:ride_sharing_user_app/helper/date_converter.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class TripDetailsScreen extends StatefulWidget {
  final String tripId;
  final bool fromNotification;
  const TripDetailsScreen({super.key, required this.tripId,this.fromNotification = false});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {

  @override
  void initState() {
    if(!widget.fromNotification){
      Get.find<RideController>().getRideDetails(widget.tripId);
    }
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<RideController>(builder: (rideController){
        return PopScope(
          onPopInvoked: (didPop){
            rideController.clearRideDetails();
          },
          child: BodyWidget(
            appBar: AppBarWidget(title: 'trip_details'.tr,subTitle: rideController.tripDetails?.refId, showBackButton: true, centerTitle: true),
            body: Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: GetBuilder<TripController>(builder: (activityController) {

                return rideController.tripDetails != null ?
                SingleChildScrollView(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    TripItemView(tripDetails: rideController.tripDetails!,isDetailsScreen: true),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    if(rideController.tripDetails?.currentStatus == 'returning' && rideController.tripDetails?.returnTime != null)...[
                      Container(width: Get.width,
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeThree,horizontal: Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.paddingSizeThree),
                              color: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.15)
                          ),
                          child: Text.rich(TextSpan(style: textRegular.copyWith(fontSize: Dimensions.fontSizeLarge,
                              color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8)), children:  [

                            TextSpan(text: 'parcel_return_estimated_time_is'.tr,
                                style: textRegular.copyWith(color: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.8),
                                    fontSize: Dimensions.fontSizeSmall)),

                            TextSpan(text: ' ${DateConverter.stringToLocalDateTime(rideController.tripDetails!.returnTime!)}',
                                style: textSemiBold.copyWith(color: Theme.of(context).colorScheme.inverseSurface, fontSize: Dimensions.fontSizeSmall)),
                          ]), textAlign: TextAlign.center)
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall)
                    ],

                    rideController.tripDetails?.type == 'parcel' ?
                    ParcelDetailsWidget(tripDetails: rideController.tripDetails!) :
                    TripDetailWidget(tripDetails: rideController.tripDetails!),

                    if(rideController.tripDetails?.driver != null)
                      RiderInfo(tripDetails: rideController.tripDetails!),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    if(rideController.tripDetails?.currentStatus == 'returning' && rideController.tripDetails?.type == 'parcel')...[
                      Center(child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                            color: Theme.of(context).cardColor,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  spreadRadius: 5,
                                  blurRadius: 10,
                                  offset: const Offset(0,1)
                              )
                            ]
                        ),
                        child: Column(children: [
                          Text('${rideController.tripDetails?.otp?[0]}  ${rideController.tripDetails?.otp?[1]}  ${rideController.tripDetails?.otp?[2]}  ${rideController.tripDetails?.otp?[3]}',style: textBold.copyWith(fontSize: 20)),

                          Text.rich(TextSpan(style: textRegular.copyWith(fontSize: Dimensions.fontSizeLarge,
                              color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8)), children:  [

                            TextSpan(text: 'please_share_the'.tr,
                                style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8),
                                    fontSize: Dimensions.fontSizeDefault)),

                            TextSpan(text: ' OTP '.tr,
                                style: textSemiBold.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeDefault)),

                            TextSpan(text: 'with_the_driver'.tr, style: textRegular.copyWith(
                                color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8),
                                fontSize: Dimensions.fontSizeDefault)),]), textAlign: TextAlign.center),
                        ]),
                      )),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      rideController.isLoading ?
                      SpinKitCircle(color: Theme.of(context).primaryColor, size: 40.0) :
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                        child: Center(child: SliderButton(
                          action: (){
                            rideController.parcelReturned(rideController.tripDetails?.id ?? '').then((value){
                              if(value.statusCode == 200){
                                showDialog(context: Get.context!, builder: (_){
                                  return parcelReceivedDialog();
                                });
                              }
                            });
                          },
                          label: Text('parcel_received'.tr,style: TextStyle(color: Theme.of(context).primaryColor)),
                          dismissThresholds: 0.5, dismissible: false, shimmer: false,
                          width: 1170, height: 40, buttonSize: 40, radius: 20,
                          icon: Center(child: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).cardColor),
                            child: Center(child: Icon(
                              Get.find<LocalizationController>().isLtr ? Icons.arrow_forward_ios_rounded : Icons.keyboard_arrow_left,
                              color: Colors.grey, size: 20.0,
                            )),
                          )),
                          isLtr: Get.find<LocalizationController>().isLtr,
                          boxShadow: const BoxShadow(blurRadius: 0),
                          buttonColor: Colors.transparent,
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
                          baseColor: Theme.of(context).primaryColor,
                        )),
                      )
                    ]

                  ]),
                ): const LoaderWidget();

              }),
            ),
          ),
        );
      }),
    );
  }

  Widget parcelReceivedDialog(){
    return Dialog(
      surfaceTintColor:Get.isDarkMode ? Theme.of(context).hintColor  : Theme.of(context).cardColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall,
          vertical: 10,
        ),
        child: SizedBox(width: Get.width,
          child: Column(mainAxisSize:MainAxisSize.min, children: [
            Align(alignment: Alignment.topRight,
              child: InkWell(onTap: ()=> Get.back(), child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).hintColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: Image.asset(
                  Images.crossIcon,
                  height: Dimensions.paddingSizeSmall,
                  width: Dimensions.paddingSizeSmall,
                  color: Theme.of(context).cardColor,
                ),
              )),
            ),

            Image.asset(Images.parcelReturnSuccessIcon,height: 80,width: 80),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: Get.width * 0.2),
              child: Text('your_parcel_returned_successfully'.tr,style: textSemiBold.copyWith(color: Theme.of(context).primaryColor),textAlign: TextAlign.center),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge)

          ]),
        ),
      ),
    );
  }
}
