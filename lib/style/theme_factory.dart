// Theme factory: build ThemeData from the active AppPalette.
import 'package:flutter/material.dart';
import 'package:youmi_dev/style/palettes.dart';

ThemeData buildTheme(AppPalette palette) {
  final colorScheme = ColorScheme(
    brightness: palette.brightness,
    primary: palette.primary,
    onPrimary: palette.background,
    secondary: palette.secondary,
    onSecondary: palette.background,
    error: const Color(0xFFB3261E),
    onError: palette.background,
    background: palette.background,
    onBackground: palette.text,
    surface: palette.surface,
    onSurface: palette.text,
  );

  final baseTextTheme = const TextTheme(
    displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.w600),
    displayMedium: TextStyle(fontSize: 40, fontWeight: FontWeight.w600),
    displaySmall: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
    headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
    headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: palette.background,
    dividerColor: palette.border,
  );

  return base.copyWith(
    appBarTheme: AppBarTheme(
      backgroundColor: palette.surface,
      foregroundColor: palette.text,
      elevation: 0,
    ),
    textTheme: baseTextTheme.apply(
      bodyColor: palette.text,
      displayColor: palette.text,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: palette.mutedText,
      textColor: palette.text,
    ),
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: palette.border),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: palette.primary),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );
}
