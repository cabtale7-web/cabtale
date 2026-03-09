import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/home/widgets/voice_search_dialog.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/set_destination/screens/set_destination_screen.dart';

class HomeSearchWidget extends StatefulWidget {
  const HomeSearchWidget({super.key});

  @override
  State<HomeSearchWidget> createState() => _HomeSearchWidgetState();
}

class _HomeSearchWidgetState extends State<HomeSearchWidget> {
  final String _fullText = 'Where to?';
  int _charIndex = 0;
  bool _isTypingForward = true;
  Timer? _typerTimer;

  @override
  void initState() {
    super.initState();
    _startTyperAnimation();
  }

  void _startTyperAnimation() {
    const speed = Duration(milliseconds: 120);
    _typerTimer = Timer.periodic(speed, (timer) {
      setState(() {
        if (_isTypingForward) {
          if (_charIndex < _fullText.length) {
            _charIndex++;
          } else {
            _isTypingForward = false;
            Future.delayed(const Duration(seconds: 1)); // pause before deleting
          }
        } else {
          if (_charIndex > 0) {
            _charIndex--;
          } else {
            _isTypingForward = true;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _typerTimer?.cancel();
    super.dispose();
  }

  String get _typedText => _fullText.substring(0, _charIndex);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Dimensions.searchBarSize,
      child: TextField(
        style: textRegular.copyWith(
          color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8),
        ),
        cursorColor: Theme.of(context).hintColor,
        autofocus: false,
        readOnly: true,
        textAlignVertical: TextAlignVertical.center,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeExtraSmall,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.3), width: 3),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.2)),
          ),
          isDense: true,

          // 👇 Typer animation text as hint
          hintText: _typedText.isEmpty ? " " : _typedText,
          hintStyle: textRegular.copyWith(
            color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.5),
          ),

          suffixIcon: IconButton(
            color: Theme.of(context).hintColor,
            onPressed: () {
              Get.dialog(const VoiceSearchDialog(), barrierDismissible: false);
            },
            icon: Image.asset(
              Images.microPhoneIcon,
              color: Get.isDarkMode ? Theme.of(context).hintColor : null,
              height: 20,
              width: 20,
            ),
          ),
          prefixIcon: IconButton(
            color: Theme.of(context).hintColor,
            onPressed: () => Get.to(() => const SetDestinationScreen()),
            icon: Image.asset(
              Images.homeSearchIcon,
              color: Get.isDarkMode ? Theme.of(context).hintColor : null,
              height: 20,
              width: 20,
            ),
          ),
        ),
        onTap: () => Get.to(() => const SetDestinationScreen()),
      ),
    );
  }
}
