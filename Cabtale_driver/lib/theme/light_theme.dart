import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  fontFamily: 'SFProText',

  primaryColor: const Color(0xFF384B70),
  primaryColorDark: const Color(0xFF2C3A59),
  disabledColor: const Color(0xFFB0B6C0),

  brightness: Brightness.light,
  hintColor: const Color(0xFF8C8FA1),

  scaffoldBackgroundColor: const Color(0xFFF3F5FA),
  canvasColor: const Color(0xFFF3F5FA),
  cardColor: Colors.white,

  colorScheme: const ColorScheme.light(
    primary: Color(0xFF384B70),
    surface: Color(0xFFF8F9FC),
    error: Color(0xFFFF5C5C),

    secondary: Color(0xFF6C8CD5),
    tertiary: Color(0xFF9BB6FF),

    tertiaryContainer: Color(0xFFE1E9FF),
    secondaryContainer: Color(0xFFD6E2FF),

    onTertiary: Color(0xFF2B3A63),
    onSecondary: Color(0xFF1E2C4F),

    onSecondaryContainer: Color(0xFF6E7FA8),
    onTertiaryContainer: Color(0xFF3D4C72),

    outline: Color(0xFFE0E3EB),
    onPrimaryContainer: Color(0xFFE8ECF5),

    primaryContainer: Color(0xFF506490),
    onErrorContainer: Color(0xFFFFE4E4),

    onPrimary: Color(0xFFFFFFFF),
    surfaceTint: Color(0xFF384B70),

    errorContainer: Color(0xFFFEECEC),
    shadow: Color(0xFFCBD3E0),

    surfaceContainer: Color(0xFFECEFF6),
    secondaryFixedDim: Color(0xFF7C8BB3),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF384B70),
    ),
  ),

  textTheme: const TextTheme(
    displayLarge: TextStyle(fontWeight: FontWeight.w300, color: Color(0xFF1F1F1F)),
    displayMedium: TextStyle(fontWeight: FontWeight.w300, color: Color(0xFF2C2C2C)),
    displaySmall: TextStyle(fontWeight: FontWeight.w300, color: Color(0xFF3A3A3A)),
    bodyLarge: TextStyle(fontWeight: FontWeight.w300, color: Color(0xFF2C2C2C)),
    bodyMedium: TextStyle(fontWeight: FontWeight.w300, color: Color(0xFF3B4461)),
    bodySmall: TextStyle(fontWeight: FontWeight.w300, color: Color(0xFF1F2A44)),
  ),
);