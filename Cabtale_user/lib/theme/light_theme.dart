import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';

ThemeData lightTheme({Color color = AppConstants.lightPrimary}) => ThemeData(
  fontFamily: AppConstants.fontFamily,


  primaryColor: const Color(0xFF384B70),

  primaryColorDark: const Color(0xFF2C3A59),
  disabledColor: const Color(0xFFB0B6C0),
  dialogBackgroundColor: Colors.white,
  scaffoldBackgroundColor: const Color(0xFFF3F5FA),
  canvasColor: const Color(0xFFF3F5FA),
  cardColor: Colors.white,
  shadowColor: const Color(0xFFCBD3E0),
  brightness: Brightness.light,

  hintColor: const Color(0xFF8C8FA1),

  colorScheme: const ColorScheme.light(


    primary: Color(0xFF384B70),
    primaryContainer: Color(0xFF506490),
    onPrimary: Color(0xFFFFFFFF),

    secondary: Color(0xFF6C8CD5),
    secondaryContainer: Color(0xFFD6E2FF),
    onSecondary: Color(0xFF1E2C4F),

    tertiary: Color(0xFF9BB6FF),
    tertiaryContainer: Color(0xFFE1E9FF),
    onTertiary: Color(0xFF2B3A63),

    surface: Color(0xFFF8F9FC),
    surfaceContainer: Color(0xFFECEFF6),
    surfaceTint: Color(0xFF384B70),
    onPrimaryContainer: Color(0xFFE8ECF5),

    error: Color(0xFFFF5C5C),
    onErrorContainer: Color(0xFFFFE4E4),
    errorContainer: Color(0xFFFEECEC),

    outline: Color(0xFFE0E3EB),
    shadow: Color(0xFFCBD3E0),

    onSecondaryContainer: Color(0xFF6E7FA8),
    onTertiaryContainer: Color(0xFF3D4C72),
    secondaryFixedDim: Color(0xFF7C8BB3),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: color,
      textStyle: const TextStyle(fontWeight: FontWeight.w500),
    ),
  ),

  textTheme: const TextTheme(
    displayLarge: TextStyle(fontWeight: FontWeight.w300, color: Color(0xFF1F1F1F)),
    displayMedium: TextStyle(fontWeight: FontWeight.w400, color: Color(0xFF2C2C2C)),
    displaySmall: TextStyle(fontWeight: FontWeight.w400, color: Color(0xFF3A3A3A)),
    bodyLarge: TextStyle(fontWeight: FontWeight.w400, color: Color(0xFF2C2C2C)),
    bodyMedium: TextStyle(fontWeight: FontWeight.w400, color: Color(0xFF3B4461)),
    bodySmall: TextStyle(fontWeight: FontWeight.w400, color: Color(0xFF1F2A44)),
  ),

  pageTransitionsTheme: const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
      TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
);
