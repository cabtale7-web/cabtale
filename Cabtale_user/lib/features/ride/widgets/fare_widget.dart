import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class FareWidget extends StatelessWidget {
  final String title;
  final String value;
  const FareWidget({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(value, style: textBold.copyWith(color: Get.isDarkMode ? Colors.white : Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge)),
      const SizedBox(height: Dimensions.paddingSizeThree),

      Text(title, style: textRegular.copyWith(color: Get.isDarkMode ? Colors.white : Theme.of(context).hintColor,fontSize: Dimensions.fontSizeDefault)),

    ]);
  }
}
