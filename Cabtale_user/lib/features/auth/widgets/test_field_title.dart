import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class TextFieldTitle extends StatelessWidget {
  final String title;
  final double textOpacity;
  const TextFieldTitle({
    super.key,
    required this.title,
    this.textOpacity = 0.85, // default slightly faded
  });

  @override
  Widget build(BuildContext context) {
    // Get color based on current theme
    final Color baseColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
      child: Text(
        title,
        style: textMedium.copyWith(
          fontSize: Dimensions.fontSizeLarge,
          color: baseColor.withOpacity(textOpacity),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
