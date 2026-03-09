import 'dart:async';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_text_field.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/auth/domain/models/sign_up_body.dart'; // (kept if needed elsewhere)
import 'package:ride_sharing_user_app/features/auth/screens/forgot_password_screen.dart';
import 'package:ride_sharing_user_app/features/auth/screens/otp_log_in_screen.dart';
import 'package:ride_sharing_user_app/features/auth/screens/sign_up_screen.dart';
import 'package:ride_sharing_user_app/features/settings/screens/policy_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // Controllers & Focus
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode phoneNode = FocusNode();
  final FocusNode passwordNode = FocusNode();
  final configController = Get.find<ConfigController>();


  // Steps: 0 = phone, 1 = password
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();

    // Restore saved phone/password if present
    final auth = Get.find<AuthController>();
    final savedPhone = auth.getUserNumber(false);
    if (savedPhone.isNotEmpty) phoneController.text = savedPhone;

    final savedPass = auth.getUserPassword(false);
    if (savedPass.isNotEmpty) {
      passwordController.text = savedPass;
      auth.setRememberMe();
      _currentStep = 1; // Jump straight to password if we already have it
    }

    // Initialize country code
    if (auth.getLoginCountryCode(false).isNotEmpty) {
      auth.countryDialCode = auth.getLoginCountryCode(false);
    } else {
      final countryCode = configController.config?.countryCode;

      if (countryCode != null) {
        auth.countryDialCode =
            CountryCode.fromCountryCode(countryCode).dialCode ?? '';
      }
    }
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return;
    }
  }

  void _goNext(AuthController auth) {
    if (_currentStep == 0) {
      // Validate phone
      final phone = phoneController.text.trim();
      if (phone.isEmpty) {
        showCustomSnackBar('phone_number_is_required'.tr);
        FocusScope.of(context).requestFocus(phoneNode);
        return;
      }
      if (!GetUtils.isPhoneNumber(auth.countryDialCode + phone)) {
        showCustomSnackBar('phone_number_is_not_valid'.tr);
        FocusScope.of(context).requestFocus(phoneNode);
        return;
      }
      setState(() => _currentStep = 1);
      Future.microtask(() => FocusScope.of(context).requestFocus(passwordNode));
    } else {
      _login(auth);
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      Future.microtask(() => FocusScope.of(context).requestFocus(phoneNode));
    }
  }

  void _login(AuthController auth) {
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    if (password.isEmpty) {
      showCustomSnackBar('password_is_required'.tr);
      FocusScope.of(context).requestFocus(passwordNode);
      return;
    }
    if (password.length < 8) {
      showCustomSnackBar('minimum_password_length_is_8'.tr);
      return;
    }
    auth.login(auth.countryDialCode, phone, password);
  }

  @override
  Widget build(BuildContext context) {
    final config = Get.find<ConfigController>().config;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        body: GetBuilder<AuthController>(builder: (authController) {
          final isStep0 = _currentStep == 0;
          final isLoading = authController.isLoading;

          return Container(
            width: double.infinity,
            height: double.infinity, // ensures full screen
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Images.background),
                fit: BoxFit.cover,   // <-- cover ensures no white space
                alignment: Alignment.topCenter, // can adjust if needed
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.1),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Center(
                        child: Image.asset(
                          "assets/image/cab.png",
                          width: 250,
                          height: 200,

                        ),
                      ),
                      Center(
                        child: Text(
                          "Login",
                          textAlign: TextAlign.center,
                          style: textBold.copyWith(
                            color: Get.isDarkMode ? Colors.white :  Theme.of(context).primaryColor,
                            fontSize: Dimensions.fontSizeOverLarge,
                          ),
                        ),
                      ),
                      // Header
                      SizedBox(height: MediaQuery.of(context).size.height * 0.001),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${AppConstants.appName} Your Ride, Your Story.',
                            style: textBold.copyWith(
                              color: Get.isDarkMode ? Colors.white : Colors.black.withOpacity(0.6),
                              fontSize: Dimensions.fontSizeDefault,
                            ),
                          ),
                          //Image.asset(Images.hand, width: 40),
                        ],
                      ),


                      // Title

                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                      // Step content
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: isStep0
                            ? Column(
                                key: const ValueKey('step-phone'),
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextField(
                                    hintText: 'phone'.tr,
                                    inputType: TextInputType.phone,
                                    countryDialCode: authController.countryDialCode,
                                    prefixHeight: 70,
                                    controller: phoneController,
                                    focusNode: phoneNode,
                                    inputAction: TextInputAction.done,
                                    onCountryChanged: (CountryCode cc) {
                                      authController.countryDialCode = cc.dialCode!;
                                      authController.setCountryCode(cc.dialCode!);
                                    },
                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeLarge),

                                ],
                              )
                            : Column(
                                key: const ValueKey('step-password'),
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextField(
                                    hintText: 'enter_password'.tr,
                                    inputType: TextInputType.text,
                                    prefixIcon: Images.lock,
                                    prefixHeight: 70,
                                    inputAction: TextInputAction.done,
                                    isPassword: true,
                                    controller: passwordController,
                                    focusNode: passwordNode,
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(
                                            Dimensions.paddingSizeSmall),
                                        child: InkWell(
                                          onTap: () =>
                                              authController.toggleRememberMe(),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 20.0,
                                                child: Checkbox(
                                                  checkColor: Theme.of(context)
                                                      .primaryColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(5),
                                                  ),
                                                  activeColor: Theme.of(context)
                                                      .primaryColor
                                                      .withOpacity(.125),
                                                  value: authController
                                                      .isActiveRememberMe,
                                                  onChanged: (bool? _) =>
                                                      authController
                                                          .toggleRememberMe(),
                                                ),
                                              ),
                                              const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeExtraSmall),
                                              Text(
                                                'remember'.tr,
                                                style: textRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      TextButton(
                                        onPressed: () => Get.to(
                                            () => const ForgotPasswordScreen()),
                                        child: Text(
                                          'forgot_password'.tr,
                                          style: textRegular.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // const SizedBox(height: Dimensions.paddingSizeLarge),

                                ],

                              ),
                      ),

                      // Controls
                      isLoading
                          ? Center(
                              child: SpinKitCircle(
                                color: Theme.of(context).primaryColor,
                                size: 40.0,
                              ),
                            )
                          : Row(
                              children: [
                                if (!isStep0)
                                  Expanded(
                                    child: Container(
                                      // A Container is used to apply the gradient, shadow, and border radius.
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12), // Sets the corner radius
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 6,
                                            offset: Offset(2, 3),
                                          ),
                                        ],
                                      ),
                                      child: ButtonWidget(
                                        buttonText: 'Back',
                                        onPressed: _goBack,
                                        height: 45,
                                        // The background color is set to transparent to show the gradient from the Container.
                                        backgroundColor: Colors.transparent,
                                        // The text color should have good contrast with the gradient.
                                        textColor: Theme.of(context).primaryColorDark,
                                      ),
                                    ),
                                  ),
                                if (!isStep0)
                                  const SizedBox(
                                      width: Dimensions.paddingSizeDefault),
                                Expanded(
                                  // child: ButtonWidget(
                                  //   buttonText:
                                  //       isStep0 ? 'next'.tr : 'log_in'.tr,
                                  //   onPressed: () => _goNext(authController),
                                  //   height: 45,
                                  //   backgroundColor: Color(0xFFFFB74D),
                                  //   //radius: 50,
                                  // ),

                                  // child: Container(
                                  //   decoration: BoxDecoration(
                                  //     gradient:  LinearGradient(
                                  //       colors: [
                                  //         // Color(0xFFFFB74D),
                                  //         // Color(0xFFFF9800)
                                  //         Theme.of(context).colorScheme.secondary,
                                  //         Theme.of(context).primaryColor,
                                  //
                                  //       ],
                                  //       begin: Alignment.topLeft,
                                  //       end: Alignment.bottomRight,
                                  //     ),
                                  //     borderRadius: BorderRadius.circular(12),
                                  //     boxShadow: [
                                  //       BoxShadow(
                                  //         color: Colors.black26,
                                  //         blurRadius: 6,
                                  //         offset: Offset(2, 3),
                                  //       ),
                                  //     ],
                                  //   ),
                                  //   child: ButtonWidget(
                                  //          buttonText:  isStep0 ? 'next'.tr : 'log_in'.tr,
                                  //       onPressed: () => _goNext(authController),
                                  //     height: 45,
                                  //     backgroundColor: Colors.transparent, // let gradient show
                                  //   ),
                                  // ),

                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: Theme.of(context).brightness == Brightness.dark
                                            ? [
                                          Theme.of(context).primaryColor, // Dark theme top
                                          Theme.of(context).primaryColor, // Dark theme bottom
                                        ]
                                            : [
                                          Theme.of(context).primaryColor, // Light theme top
                                          Theme.of(context).primaryColor,          // Light theme bottom
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.black54
                                              : Colors.black26,
                                          blurRadius: 6,
                                          offset: const Offset(2, 3),
                                        ),
                                      ],
                                    ),
                                    child: ButtonWidget(
                                      buttonText: isStep0 ? 'next'.tr : 'log_in'.tr,
                                      onPressed: () => _goNext(authController),
                                      height: 45,
                                      backgroundColor: Colors.transparent, // let gradient show
                                      textColor: Colors.white,
                                      // ✅ always visible on gradient
                                    ),

                                  )
                                  ,

                                ),

                              ],
                            ),

                      // const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                      // Secondary actions (only on Step 0 to keep focus)
                      if (isStep0) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white54   // for Dark theme
                                    : Colors.black87,  // for Light theme
                              ),
                            ),


                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeSmall,
                                vertical: 8,
                              ),
                              child: Text(
                                'or'.tr,
                                style: textRegular.copyWith(
                                  color: Theme.of(context).textTheme.bodyMedium?.color, // adapts to theme
                                ),
                              ),
                            ),

                            Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white54   // for Dark theme
                                    : Colors.black87,  // for Light theme
                              ),
                            )

                          ],
                        ),

                        // ButtonWidget(
                        //
                        //   showBorder: true,
                        //   borderWidth: 1,
                        //   transparent: true,
                        //   buttonText: 'otp_login'.tr,
                        //   borderColor: Colors.black,
                        //   textColor: Colors.black,
                        //   onPressed: () => Get.to(
                        //       () => const OtpLoginScreen(fromSignIn: true)),
                        // ),

                        ButtonWidget(
                          showBorder: true,
                          borderWidth: 1,
                          transparent: true,
                          buttonText: 'otp_login'.tr,
                          borderColor: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          textColor: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          onPressed: () => Get.to(() => OtpLoginScreen(fromSignIn: true)),
                        ),





                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        if (!(config?.externalSystem ?? false))
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${'do_not_have_an_account'.tr} ',
                                style: textMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Colors.white70,
                                ),
                              ),
                              // ButtonWidget(
                              //   buttonText: 'sign_up'.tr,
                              //   onPressed: () =>
                              //       Get.to(() => const SignUpScreen()),
                              //   width: 120,
                              //   //radius: 20,
                              //   fontSize: Dimensions.fontSizeSmall,
                              // )
                              SizedBox(width: 3,),

                              // new Navigator for the Signup Screen //

                              TextButton(
                                onPressed: () {
                                  Get.off(() => const SignUpScreen());
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(50,30),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,

                                ),
                                child: Text('sign_up'.tr, style: textMedium.copyWith(
                                  color: Theme.of(context).primaryColorDark,
                                  fontSize: Dimensions.fontSizeDefault,
                                )),
                              )
                            ],
                          ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1),
                        InkWell(
                          onTap: () => Get.to(() => const PolicyScreen()),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "terms_and_condition".tr,
                                style: textMedium.copyWith(
                                  decoration: TextDecoration.underline,
                                  color: Get.isDarkMode ? Colors.white : Colors.white70,
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        // External system banner preserved as-is
        // bottomNavigationBar:
        //     GetBuilder<AuthController>(builder: (authController) {
        //   return ((Get.find<ConfigController>().config?.externalSystem ??
        //               false) &&
        //           authController.showNavigationBar)
        //       ? Container(
        //           padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        //           decoration: BoxDecoration(
        //             color:
        //                 Theme.of(Get.context!).textTheme.titleMedium!.color!,
        //           ),
        //           child: Column(mainAxisSize: MainAxisSize.min, children: [
        //             Row(children: [
        //               Padding(
        //                 padding: const EdgeInsets.all(
        //                     Dimensions.paddingSizeExtraSmall),
        //                 child: Icon(Icons.info,
        //                     size: 20, color: Theme.of(context).cardColor),
        //               ),
        //               const SizedBox(width: Dimensions.paddingSizeSmall),
        //               Expanded(
        //                 child: Row(
        //                     crossAxisAlignment: CrossAxisAlignment.start,
        //                     children: [
        //                       Expanded(
        //                         child: Column(
        //                             crossAxisAlignment:
        //                                 CrossAxisAlignment.start,
        //                             children: [
        //                               Text('this_is_not_an_independent_app'.tr,
        //                                   style: textRegular.copyWith(
        //                                       color: Theme.of(context)
        //                                           .cardColor)),
        //                               const SizedBox(
        //                                   height:
        //                                       Dimensions.paddingSizeExtraSmall),
        //                               RichText(
        //                                 text: TextSpan(
        //                                   text:
        //                                       'this_app_is_connected_with_6ammart'
        //                                           .tr,
        //                                   style: textRegular.copyWith(
        //                                       color: Theme.of(context)
        //                                           .cardColor
        //                                           .withOpacity(0.7),
        //                                       fontSize: Dimensions
        //                                           .fontSizeExtraSmall),
        //                                   children: [
        //                                     TextSpan(
        //                                       text:
        //                                           ' ${'click_here_to_sigh_up'.tr}',
        //                                       style: textRegular.copyWith(
        //                                         color: Theme.of(context)
        //                                             .colorScheme
        //                                             .surfaceContainer,
        //                                         fontSize: Dimensions
        //                                             .fontSizeExtraSmall,
        //                                         decoration:
        //                                             TextDecoration.underline,
        //                                       ),
        //                                       recognizer:
        //                                           TapGestureRecognizer()
        //                                             ..onTap = () async {
        //                                               navigateToMart(
        //                                                   'sixammart://open?country_code=&phone=signUp&password=}');
        //                                             },
        //                                     ),
        //                                     TextSpan(
        //                                       text: '  ${'or'.tr}  ',
        //                                       style: textRegular.copyWith(
        //                                         color: Theme.of(context)
        //                                             .cardColor,
        //                                         fontSize: Dimensions
        //                                             .fontSizeExtraSmall,
        //                                       ),
        //                                     ),
        //                                     TextSpan(
        //                                       text: 'download_mart'.tr,
        //                                       style: textRegular.copyWith(
        //                                         color: Theme.of(context)
        //                                             .colorScheme
        //                                             .surfaceContainer,
        //                                         fontSize: Dimensions
        //                                             .fontSizeExtraSmall,
        //                                         decoration:
        //                                             TextDecoration.underline,
        //                                       ),
        //                                       recognizer:
        //                                           TapGestureRecognizer()
        //                                             ..onTap = () async {
        //                                               if (GetPlatform
        //                                                       .isAndroid &&
        //                                                   Get.find<
        //                                                               ConfigController>()
        //                                                           .config
        //                                                           ?.martPlayStoreUrl !=
        //                                                       null) {
        //                                                 navigateToMart(Get.find<
        //                                                             ConfigController>()
        //                                                         .config!
        //                                                         .martPlayStoreUrl!);
        //                                               } else if (GetPlatform
        //                                                       .isIOS &&
        //                                                   Get.find<
        //                                                               ConfigController>()
        //                                                           .config
        //                                                           ?.martAppStoreUrl !=
        //                                                       null) {
        //                                                 navigateToMart(Get.find<
        //                                                             ConfigController>()
        //                                                         .config!
        //                                                         .martAppStoreUrl!);
        //                                               } else {
        //                                                 showCustomSnackBar(
        //                                                     'contact_with_support'
        //                                                         .tr);
        //                                               }
        //                                             },
        //                                     )
        //                                   ],
        //                                 ),
        //                               )
        //                             ]),
        //                       ),
        //                       InkWell(
        //                         onTap: () =>
        //                             authController.toggleNavigationBar(),
        //                         child: Padding(
        //                           padding: const EdgeInsets.symmetric(
        //                               horizontal:
        //                                   Dimensions.paddingSizeExtraSmall),
        //                           child: Icon(Icons.clear,
        //                               color: Theme.of(context).cardColor),
        //                         ),
        //                       )
        //                     ]),
        //
        //               ),
        //             ]),
        //
        //           ]),
        //
        //         )
        //       : const SizedBox(height: 80,);
        // }),
      ),
    );
  }

  void navigateToMart(String url) async {
    if (GetPlatform.isAndroid) {
      try {
        await launchUrl(Uri.parse(url));
      } catch (exception) {
        navigateToStores(url);
      }
    } else if (GetPlatform.isIOS) {
      if (await launchUrl(Uri.parse(url))) {
      } else {
        navigateToStores(url);
      }
    }
  }

  void navigateToStores(String url) async {
    if (GetPlatform.isAndroid &&
        Get.find<ConfigController>().config?.martPlayStoreUrl != null) {
      await launchUrl(
          Uri.parse(Get.find<ConfigController>().config!.martPlayStoreUrl!));
    } else if (GetPlatform.isIOS &&
        Get.find<ConfigController>().config?.martAppStoreUrl != null) {
      await launchUrl(
          Uri.parse(Get.find<ConfigController>().config!.martAppStoreUrl!));
    } else {
      showCustomSnackBar('contact_with_support'.tr);
    }
  }
}
