

import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  fontFamily: 'SFProText',
  brightness: Brightness.dark,

  primaryColor: const Color(0xFF384B70),
  primaryColorDark: const Color(0xFF384B70),

  scaffoldBackgroundColor: const Color(0xFF121212),
  cardColor: const Color(0xFF1E2230),
  hintColor: const Color(0xFF9CA3AF),

  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF384B70),
    onPrimary: Color(0xFFFFFFFF),

    primaryContainer: Color(0xFF4B5F8A),
    onPrimaryContainer: Color(0xFFDCE1F0),

    secondary: Color(0xFF6C8CD5),
    onSecondary: Color(0xFF10131E),

    secondaryContainer: Color(0xFF28314A),
    onSecondaryContainer: Color(0xFFD8E1FF),

    tertiary: Color(0xFF9BB6FF),
    onTertiary: Color(0xFF0E1320),

    tertiaryContainer: Color(0xFF32416A),
    onTertiaryContainer: Color(0xFFD6DEFF),

    surface: Color(0xFF181B24),
    surfaceContainer: Color(0xFF202533),
    onSurface: Color(0xFFEAEAEA),

    surfaceTint: Color(0xFF384B70),

    error: Color(0xFFFF5C5C),
    onError: Color(0xFFFFFFFF),

    errorContainer: Color(0xFF3B0000),
    onErrorContainer: Color(0xFFFFE4E4),

    outline: Color(0xFFFFFFFF),

    secondaryFixedDim: Color(0xFF6271A3),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF384B70),
      textStyle: const TextStyle(fontWeight: FontWeight.w500),
    ),
  ),

  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontWeight: FontWeight.w400,
      color: Color(0xFFEAEAEA),
    ),
    displayMedium: TextStyle(
      fontWeight: FontWeight.w400,
      color: Color(0xFFD0D3DB),
    ),
    displaySmall: TextStyle(
      fontWeight: FontWeight.w400,
      color: Color(0xFFBFC3CE),
    ),
    bodyLarge: TextStyle(
      fontWeight: FontWeight.w400,
      color: Color(0xFFDEE2E9),
    ),
    bodyMedium: TextStyle(
      fontWeight: FontWeight.w400,
      color: Color(0xFFBAC2D8),
    ),
    bodySmall: TextStyle(
      fontWeight: FontWeight.w400,
      color: Color(0xFF9FA8C3),
    ),
  ),
);