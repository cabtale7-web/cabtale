import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/auth/screens/otp_log_in_screen.dart'; // (left as-is even though not used)
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/auth/screens/sign_up_screen.dart';
import 'package:ride_sharing_user_app/features/dashboard/controllers/bottom_menu_controller.dart';
import 'package:ride_sharing_user_app/features/auth/screens/forgot_password_screen.dart';
import 'package:ride_sharing_user_app/features/html/screens/policy_viewer_screen.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/text_field_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final FocusNode phoneNode = FocusNode();
  final FocusNode passwordNode = FocusNode();

  // 0 = phone step, 1 = password step
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();

    final auth = Get.find<AuthController>();
    final splash = Get.find<SplashController>();

    if (auth.getUserNumber().isNotEmpty) {
      phoneController.text = auth.getUserNumber();
    }
    passwordController.text = auth.getUserPassword();
    if (passwordController.text.isNotEmpty) {
      auth.setRememberMe();
      _currentStep = 1; // jump to password if saved
    }

    if (auth.getLoginCountryCode().isNotEmpty) {
      auth.countryDialCode = auth.getLoginCountryCode();
    } else if (splash.config?.countryCode != null) {
      auth.countryDialCode = CountryCode
              .fromCountryCode(splash.config!.countryCode!)
          .dialCode!;
    }

    // Put initial focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentStep == 0) {
        FocusScope.of(context).requestFocus(phoneNode);
      } else {
        FocusScope.of(context).requestFocus(passwordNode);
      }
    });
  }

  void _goNext(AuthController auth) {
    if (_currentStep == 0) {
      final phone = phoneController.text.trim();
      if (phone.isEmpty) {
        showCustomSnackBar('phone_is_required'.tr);
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
      FocusScope.of(context).requestFocus(passwordNode);
      return;
    }
    auth.login(auth.countryDialCode, phone, password);
  }

  bool _anyLoading(AuthController a, ProfileController p, RideController r, LocationController l) {
    return a.isLoading || a.updateFcm || p.isLoading || r.isLoading || l.lastLocationLoading;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (val) async {
        Get.find<BottomMenuController>().exitApp();
        return;
      },
      child: Scaffold(
        body: GetBuilder<AuthController>(builder: (authController) {
          return GetBuilder<ProfileController>(builder: (profileController) {
            return GetBuilder<RideController>(builder: (rideController) {
              return GetBuilder<LocationController>(builder: (locationController) {
                final isLoading = _anyLoading(authController, profileController, rideController, locationController);

                return Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: Dimensions.paddingSizeSignUp),

                          Image.asset(Images.logoWithName, height: 60),
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          Text(
                            '${AppConstants.appName} Your Ride, Your Story.',
                            style: textBold.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontSize: Dimensions.fontSizeLarge,
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.1),

                          Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'log_in'.tr,
                                  textAlign: TextAlign.center,
                                  style: textBold.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: Dimensions.fontSizeExtraLarge,
                                  ),
                                ),
                                //const SizedBox(height: 4),
                                // Text(
                                //   'log_in_message'.tr,
                                //   textAlign: TextAlign.center,
                                //   style: textRegular.copyWith(color: Theme.of(context).hintColor),
                                // ),
                                const SizedBox(height: Dimensions.paddingSizeLarge),
                              ],
                            ),
                          ),

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: _currentStep == 0
                                ? Column(
                                    key: const ValueKey('step-phone'),
                                    children: [
                                      TextFieldWidget(
                                        hintText: 'phone'.tr,
                                        inputType: TextInputType.number,
                                        countryDialCode: authController.countryDialCode,
                                        controller: phoneController,
                                        focusNode: phoneNode,
                                        onCountryChanged: (CountryCode countryCode) {
                                          authController.countryDialCode = countryCode.dialCode!;
                                          authController.setCountryCode(countryCode.dialCode!);
                                        },
                                      ),
                                      const SizedBox(height: Dimensions.paddingSizeDefault),
                                    ],
                                  )
                                : Column(
                                    key: const ValueKey('step-password'),
                                    children: [
                                      TextFieldWidget(
                                        hintText: 'password'.tr,
                                        inputType: TextInputType.text,
                                        prefixIcon: Images.lock,
                                        inputAction: TextInputAction.done,
                                        focusNode: passwordNode,
                                        prefixHeight: 70,
                                        isPassword: true,
                                        controller: passwordController,
                                      ),
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                            child: InkWell(
                                              onTap: () => authController.toggleRememberMe(),
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: 20.0,
                                                    child: Checkbox(
                                                      checkColor: Theme.of(context).primaryColor,
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                                      activeColor: Theme.of(context).primaryColor.withOpacity(.125),
                                                      value: authController.isActiveRememberMe,
                                                      onChanged: (bool? _) => authController.toggleRememberMe(),
                                                    ),
                                                  ),
                                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                                  Text(
                                                    'remember'.tr,
                                                    style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton(
                                              onPressed: () => Get.to(() => const ForgotPasswordScreen()),
                                              child: Text(
                                                'forgot_password'.tr,
                                                style: textRegular.copyWith(
                                                  fontSize: Dimensions.fontSizeSmall,
                                                  color: Theme.of(context).primaryColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: Dimensions.paddingSizeDefault),
                                    ],
                                  ),
                          ),

                          // -------- Controls (Back/Next or Login) --------
                          isLoading
                              ? Center(
                                  child: SpinKitCircle(
                                    color: Theme.of(context).primaryColor,
                                    size: 40.0,
                                  ),
                                )
                              : Row(
                                  children: [
                                    if (_currentStep == 1)
                                      Expanded(
                                        child: ButtonWidget(
                                          buttonText: 'Back',
                                          onPressed: _goBack,
                                          radius: 10,
                                          height: 45,
                                          backgroundColor: Theme.of(context).cardColor,
                                          textColor: Theme.of(context).primaryColor,
                                          showBorder: true,
                                          borderColor: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    if (_currentStep == 1) const SizedBox(width: Dimensions.paddingSizeDefault),
                                    Expanded(
                                      child: ButtonWidget(
                                        buttonText: _currentStep == 0 ? 'next'.tr : 'log_in'.tr,
                                        onPressed: () => _currentStep == 0
                                            ? _goNext(authController)
                                            : _login(authController),
                                        radius: 10,
                                        height: 45,
                                      ),
                                    ),
                                  ],
                                ),

                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          // Secondary actions: show only on Step 0 (keeps focus, matches your other screen's logic)
                          if (_currentStep == 0) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(width: Dimensions.paddingSizeSmall),
                                GetBuilder<AuthController>(builder: (a) {
                                  return a.isLoading
                                      ? SpinKitCircle(
                                          color: Theme.of(context).primaryColor,
                                          size: 24.0,
                                        )
                                      : Flexible(
                                          fit: FlexFit.loose,
                                          child: ButtonWidget(
                                            buttonText: 'Become a Driver / ड्राइवर बनें',
                                            onPressed: () => launchUrlString('https://cabtale.com/contact-us/'),
                                            radius: 10,
                                          ),
                                        );
                                }),
                              ],
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                            InkWell(
                              onTap: () => Get.to(() => const PolicyViewerScreen()),
                              child: Padding(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                child: Text(
                                  "terms_and_condition".tr,
                                  style: textMedium.copyWith(
                                    decoration: TextDecoration.underline,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              });
            });
          });
        }),
      ),
    );
  }
}
