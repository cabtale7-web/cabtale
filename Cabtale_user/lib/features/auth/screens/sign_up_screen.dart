import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_text_field.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/auth/domain/models/sign_up_body.dart';
import 'package:ride_sharing_user_app/features/auth/screens/sign_in_screen.dart';
import 'package:ride_sharing_user_app/features/auth/widgets/test_field_title.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controllers
  final TextEditingController fNameController = TextEditingController();
  final TextEditingController lNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController referralCodeController = TextEditingController();

  // Focus nodes
  final FocusNode fNameNode = FocusNode();
  final FocusNode lNameNode = FocusNode();
  final FocusNode phoneNode = FocusNode();
  final FocusNode passwordNode = FocusNode();
  final FocusNode confirmPasswordNode = FocusNode();
  final FocusNode referralNode = FocusNode();

  // Step state
  int _currentStep = 0;

  bool get _referralEnabled =>
      Get.find<ConfigController>().config?.referralEarningStatus ?? false;

  int get _lastStepIndex => _referralEnabled ? 5 : 4;

  @override
  void initState() {
    super.initState();
    final cfg = Get.find<ConfigController>().config;
    if (cfg?.countryCode != null) {
      Get.find<AuthController>().countryDialCode =
      CountryCode.fromCountryCode(cfg!.countryCode!).dialCode!;
    }
  }

  // Navigation
  void _back() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  void _next(AuthController authController) {
    if (_validateCurrentStep(authController)) {
      if (_currentStep < _lastStepIndex) {
        setState(() => _currentStep++);
      } else {
        _submit(authController);
      }
    }
  }

  // Validation per step
  bool _validateCurrentStep(AuthController authController) {
    final fName = fNameController.text.trim();
    final lName = lNameController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    switch (_currentStep) {
      case 0:
        if (fName.isEmpty) {
          showCustomSnackBar('first_name_is_required'.tr);
          FocusScope.of(context).requestFocus(fNameNode);
          return false;
        }
        return true;
      case 1:
        if (lName.isEmpty) {
          showCustomSnackBar('last_name_is_required'.tr);
          FocusScope.of(context).requestFocus(lNameNode);
          return false;
        }
        return true;
      case 2:
        if (phone.isEmpty) {
          showCustomSnackBar('phone_is_required'.tr);
          FocusScope.of(context).requestFocus(phoneNode);
          return false;
        }
        if (!GetUtils.isPhoneNumber(authController.countryDialCode + phone)) {
          showCustomSnackBar('phone_number_is_not_valid'.tr);
          FocusScope.of(context).requestFocus(phoneNode);
          return false;
        }
        return true;
      case 3:
        if (password.isEmpty) {
          showCustomSnackBar('password_is_required'.tr);
          FocusScope.of(context).requestFocus(passwordNode);
          return false;
        }
        if (password.length < 8) {
          showCustomSnackBar('minimum_password_length_is_8'.tr);
          FocusScope.of(context).requestFocus(passwordNode);
          return false;
        }
        return true;
      case 4:
        if (confirmPassword.isEmpty) {
          showCustomSnackBar('confirm_password_is_required'.tr);
          FocusScope.of(context).requestFocus(confirmPasswordNode);
          return false;
        }
        if (password != confirmPassword) {
          showCustomSnackBar('password_is_mismatch'.tr);
          FocusScope.of(context).requestFocus(confirmPasswordNode);
          return false;
        }
        return true;
      case 5:
        return true; // referral optional
      default:
        return true;
    }
  }

  void _submit(AuthController authController) {
    final fName = fNameController.text.trim();
    final lName = lNameController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (fName.isEmpty ||
        lName.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showCustomSnackBar('please_fill_all_required_fields'.tr);
      return;
    }

    authController.register(SignUpBody(
      fName: fName,
      lName: lName,
      phone: authController.countryDialCode + phone,
      password: password,
      confirmPassword: confirmPassword,
      referralCode: referralCodeController.text.trim(),
    ));
  }

  // Field per step
  Widget _buildStepField(AuthController authController) {
    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFieldTitle(title: 'first_name'.tr),
            CustomTextField(
              inputType: TextInputType.name,
              prefixIcon: Images.person,
              controller: fNameController,
              focusNode: fNameNode,
              nextFocus: lNameNode,
              inputAction: TextInputAction.next,
              prefixHeight: 70,
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFieldTitle(title: 'last_name'.tr),
            CustomTextField(
              capitalization: TextCapitalization.words,
              inputType: TextInputType.name,
              prefixIcon: Images.person,
              controller: lNameController,
              focusNode: lNameNode,
              nextFocus: phoneNode,
              inputAction: TextInputAction.next,
              prefixHeight: 70,
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFieldTitle(title: 'phone'.tr),
            CustomTextField(
              hintText: 'phone'.tr,
              inputType: TextInputType.number,
              countryDialCode: authController.countryDialCode,
              controller: phoneController,
              focusNode: phoneNode,
              nextFocus: passwordNode,
              inputAction: TextInputAction.next,
              onCountryChanged: (CountryCode cc) {
                authController.countryDialCode = cc.dialCode!;
                authController.setCountryCode(cc.dialCode!);
                FocusScope.of(context).requestFocus(phoneNode);
              },
            ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFieldTitle(title: 'password'.tr),
            CustomTextField(
              hintText: 'enter_password'.tr,
              inputType: TextInputType.text,
              prefixIcon: Images.password,
              isPassword: true,
              controller: passwordController,
              focusNode: passwordNode,
              nextFocus: confirmPasswordNode,
              inputAction: TextInputAction.next,
              prefixHeight: 70,
            ),
          ],
        );
      case 4:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFieldTitle(title: 'confirm_password'.tr),
            CustomTextField(
              hintText: 'enter_confirm_password'.tr,
              inputType: TextInputType.text,
              prefixIcon: Images.password,
              isPassword: true,
              controller: confirmPasswordController,
              focusNode: confirmPasswordNode,
              nextFocus: _referralEnabled ? referralNode : null,
              inputAction: _referralEnabled ? TextInputAction.next : TextInputAction.done,
              prefixHeight: 70,
            ),
          ],
        );
      case 5:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFieldTitle(title: 'refer_code'.tr),
            CustomTextField(
              hintText: 'refer_code'.tr,
              inputType: TextInputType.text,
              controller: referralCodeController,
              focusNode: referralNode,
              inputAction: TextInputAction.done,
              prefixIcon: Images.referralIcon1,
              prefixHeight: 70,
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // Controls
  Widget _stepControls(AuthController authController) {
    final isLast = _currentStep == _lastStepIndex;
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(2, 3))
                ],
              ),
              child: ButtonWidget(
                buttonText: 'Back',
                onPressed: _back,
                height: 45,
                backgroundColor: Colors.transparent,
                textColor: Theme.of(context).primaryColorDark
                ,
              ),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: Dimensions.paddingSizeDefault),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(2, 3))
              ],
            ),
            child: ButtonWidget(
              buttonText: isLast ? 'submit'.tr : 'next'.tr,
              onPressed: () => _next(authController),
              height: 45,
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        body: GetBuilder<AuthController>(builder: (authController) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Images.background),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.1), BlendMode.darken),
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.asset(
                          "assets/image/cab2.png",
                          width: 250,
                          height: 200,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported, size: 50),
                        ),
                      ),
                      // const SizedBox(height: Dimensions.paddingSizeSmall),
                      Center(
                        child: Text(
                          'sign_up'.tr,
                          textAlign: TextAlign.center,
                          style: textBold.copyWith(
                            fontSize: Dimensions.fontSizeOverLarge,
                            foreground: Paint()
                              ..shader = LinearGradient(
                                colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context).primaryColor
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(Rect.fromLTWH(0, 0, 200, 70)),
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.001),
                      Center(
                        // child: Text(
                        //   "Sign up to start your journey with us",
                        //   textAlign: TextAlign.center,
                        //   style: TextStyle(
                        //     fontSize: Dimensions.fontSizeDefault,
                        //     fontWeight: FontWeight.w600,
                        //     color: Get.isDarkMode ? Colors.white : Colors.black54,
                        //     height: 1.4,
                        //     letterSpacing: 0.5,
                        //   ),
                        // ),

                        child: Center(
                          child: Text(
                            "Sign up to start your journey with us",
                            textAlign: TextAlign.center,
                            style: textBold.copyWith(
                              color: Get.isDarkMode
                                  ? Colors.white
                                  : Colors.black.withOpacity(0.6),
                              fontSize: Dimensions.fontSizeDefault,
                              height: 1.4,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      _buildStepField(authController),
                      const SizedBox(height: Dimensions.paddingSizeLarge * 0.8),
                      authController.isLoading
                          ? Center(
                        child: SpinKitCircle(
                          color: Theme.of(context).primaryColor,
                          size: 40.0,
                        ),
                      )
                          : _stepControls(authController),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      Center(
                        child: Text(
                          '${'step'.tr} ${_currentStep + 1} / ${_lastStepIndex + 1}',
                          style: textRegular.copyWith(
                            color: Theme.of(context).primaryColorDark,
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Text(
                          //   '${'Already have an account ? '.tr} ',
                          //   style: textRegular.copyWith(
                          //     fontSize: Dimensions.fontSizeSmall,
                          //     color: AppConstants.whiteless,
                          //   ),
                          // ),
                          Text(
                            '${'Already have an account ? '.tr} ',
                            style: textMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Colors.white70,
                            ),
                          ),

                          TextButton(
                            onPressed: () => Get.off(() => const SignInScreen()),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(50, 30),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Login'.tr,
                              style: textMedium.copyWith(
                                color: Theme.of(context).primaryColorDark,
                                fontSize: Dimensions.fontSizeDefault,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 130),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
