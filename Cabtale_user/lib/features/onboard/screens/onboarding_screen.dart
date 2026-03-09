import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/onboard/controllers/on_board_page_controller.dart';
import 'package:ride_sharing_user_app/features/onboard/widget/pager_content.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/auth/screens/sign_in_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          /// Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage("assets/image/bg.png"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.25),
                  BlendMode.darken,
                ),
              ),
            ),
          ),

          /// Main Content with Controller
          GetBuilder<OnBoardController>(
            builder: (onBoardController) {
              return Column(
                children: [

                  /// PageView
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (value) {
                        onBoardController.onPageChanged(value);
                      },
                      itemCount: AppConstants.onBoardPagerData.length,
                      itemBuilder: (context, index) {
                        return PagerContent(
                          image: AppConstants.onBoardPagerData[index].image,
                          text: AppConstants.onBoardPagerData[index].title,
                          index: index,
                        );
                      },
                    ),
                  ),

                  /// Bottom Controls
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: Dimensions.paddingSizeExtraLarge,
                    ),
                    child: onBoardController.pageIndex ==
                        AppConstants.onBoardPagerData.length - 1
                        ? SizedBox(
                      width: 200,
                      child: ButtonWidget(
                        transparent: true,
                        textColor: Colors.white,
                        showBorder: true,
                        radius: 100,
                        borderColor:
                        Colors.white.withOpacity(0.5),
                        buttonText: 'get_started'.tr,
                        onPressed: () {
                          Get.find<ConfigController>().disableIntro();
                          Get.offAll(() => const SignInScreen());
                        },
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        /// Next Arrow
                        IconButton(
                          onPressed: () {
                            if (onBoardController.pageIndex ==
                                AppConstants.onBoardPagerData.length - 1) {
                              Get.find<ConfigController>().disableIntro();
                              Get.offAll(() => const SignInScreen());
                            } else {
                              onBoardController.onPageIncrement();
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.ease,
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.arrow_forward,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),

                        SizedBox(width: Get.width * 0.15),

                        /// Skip
                        TextButton(
                          onPressed: () {
                            Get.find<ConfigController>().disableIntro();
                            Get.offAll(() => const SignInScreen());
                          },
                          child: Text(
                            'skip'.tr,
                            style: textRegular.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
