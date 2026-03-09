import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/refer_and_earn/controllers/refer_and_earn_controller.dart';
import 'package:ride_sharing_user_app/features/refer_and_earn/screens/refer_and_earn_screen.dart';
import 'package:ride_sharing_user_app/helper/date_converter.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/notification/domain/models/notification_model.dart';

class NotificationCardWidget extends StatelessWidget {
  final Notifications notification;
  final Notifications? previousNotification;
  final Notifications? nextNotification;
  const NotificationCardWidget({super.key, required this.notification, required this.nextNotification, required this.previousNotification});

  @override
  Widget build(BuildContext context) {
    int currentNotificationMinutes = calculateMinute(notification.createdAt!);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: InkWell(
        onTap: () {
          Get.bottomSheet(Container(
            width: Get.width,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius:const BorderRadius.only(
                topLeft: Radius.circular(Dimensions.paddingSizeLarge),
                topRight: Radius.circular(Dimensions.paddingSizeLarge),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(mainAxisSize: MainAxisSize.min,children: [
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSize),
                  margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Get.isDarkMode ?
                    Theme.of(context).scaffoldBackgroundColor :
                    Theme.of(context).primaryColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                  ),
                  child: Image.asset(
                    notification.action == 'referral_reward_received' ?
                    Images.notificationEarningIcon :
                    Images.activityIcon,
                    width: 20,height: 20,
                    fit: BoxFit.cover,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Text(notification.title ?? '',style: textBold,textAlign: TextAlign.center),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Text(
                  notification.description ?? '',textAlign: TextAlign.center,
                  style: textRegular.copyWith(color: Theme.of(context).hintColor),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                if(notification.action == 'referral_reward_received')
                  InkWell(
                    onTap: (){
                      Get.find<ReferAndEarnController>().setReferralTypeIndex(1);
                      Get.to(() => const ReferAndEarnScreen());
                    },
                      child: Text('earning_history'.tr,style: textRegular.copyWith(color: Theme.of(context).colorScheme.surfaceContainer,decoration: TextDecoration.underline))
                  ),

                const SizedBox(height: 30),
              ]),
            ),
          ));
        },
        child: Column(children: [
          if(previousNotification == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              child: Text(DateConverter.isoStringToLocalDateAndMonthOnly(notification.createdAt!) ==  DateConverter.localDateTimeToDateAndMonthOnly(DateTime.now()) ?
              'today'.tr :
              DateConverter.isoStringToLocalDateAndMonthOnly(notification.createdAt!) ==  DateConverter.localDateTimeToDateAndMonthOnly(DateTime.now().subtract(const Duration(days: 1))) ?
              'last_day'.tr :
              DateConverter.isoDateTimeStringToDateOnly(notification.createdAt!)),
            ),

          Container(
            decoration: BoxDecoration(
              color: Get.isDarkMode ?
              Theme.of(context).scaffoldBackgroundColor :
              Theme.of(context).primaryColor.withOpacity(0.07),
              borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusLarge)),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeLarge,
            ),
            margin: const EdgeInsets.symmetric(vertical: 2),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSize),
                margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Get.isDarkMode ?
                  Theme.of(context).scaffoldBackgroundColor :
                  Theme.of(context).primaryColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                ),
                child: Image.asset(
                  Images.activityIcon,
                  width: 20,height: 20,
                  fit: BoxFit.cover,
                  color: Theme.of(context).primaryColor,
                ),
              ),

              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Padding(
                      padding: const EdgeInsets.only(right: Dimensions.paddingSizeExtraLarge),
                      child: Text(notification.title ?? '',
                        style: textMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                        maxLines: 1,overflow: TextOverflow.ellipsis,
                      ),
                    )),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                      child: Row(children: [
                        Text(
                          currentNotificationMinutes < 60 ?
                          '$currentNotificationMinutes ${'min_ago'.tr}' :
                          DateConverter.isoDateTimeStringToLocalTime(notification.createdAt!),
                          style: textRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        Icon(
                          Icons.alarm,
                          size: Dimensions.fontSizeLarge,
                          color: Theme.of(context).hintColor.withOpacity(0.5),
                        ),
                      ]),
                    ),
                  ]),

                  Text(notification.description ?? '',maxLines: 1,overflow: TextOverflow.ellipsis),

                ]),
              ),
            ]),
          ),

          if(((nextNotification == null) && (previousNotification != null) &&
              (DateConverter.isoStringToLocalDateAndMonthOnly(notification.createdAt!) != DateConverter.isoStringToLocalDateAndMonthOnly(previousNotification!.createdAt!))))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              child: Text(DateConverter.isoStringToLocalDateAndMonthOnly(notification.createdAt!) ==  DateConverter.localDateTimeToDateAndMonthOnly(DateTime.now().subtract(const Duration(days: 1))) ?
              'last_day'.tr :
              DateConverter.isoDateTimeStringToDateOnly(notification.createdAt ?? '2024-07-13T04:59:40.000000Z')),
            ),

          if((nextNotification != null) &&
              (DateConverter.isoStringToLocalDateAndMonthOnly(notification.createdAt!) != DateConverter.isoStringToLocalDateAndMonthOnly(nextNotification!.createdAt!)))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              child: Text(DateConverter.isoStringToLocalDateAndMonthOnly(nextNotification!.createdAt!) ==  DateConverter.localDateTimeToDateAndMonthOnly(DateTime.now().subtract(const Duration(days: 1))) ?
              'last_day'.tr :
              DateConverter.isoDateTimeStringToDateOnly(nextNotification?.createdAt ?? '2024-07-13T04:59:40.000000Z')),
            ),
        ]),
      ),
    );
  }
}

int calculateMinute(String isoDateTime){
  DateTime dateTime = DateConverter.isoStringToLocalDate(isoDateTime);
  return DateTime.now().difference(dateTime).inMinutes;
}
