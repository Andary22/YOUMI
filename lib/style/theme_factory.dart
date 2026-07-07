// Theme factory: build a full Material 3 ThemeData from the active
// AppPalette. Every screen inherits button, card, dialog, chip, and input
// styling from here, so this is the single place to change the app's look.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youmi_dev/style/palettes.dart';

const double _kRadiusSmall = 14;
const double _kRadiusMedium = 20;
const double _kRadiusLarge = 28;

/// Picks black or white text/icon color depending on the luminance of [bg],
/// so accent buttons stay readable regardless of which palette is active.
Color _onColorFor(Color bg) {
  return bg.computeLuminance() > 0.5
      ? const Color(0xFF15161A)
      : const Color(0xFFFFFFFF);
}

Color _mix(Color a, Color b, double amount) {
  return Color.lerp(a, b, amount) ?? a;
}

Color _tint(Color color, Color accent, double amount) {
  return Color.lerp(color, accent, amount) ?? color;
}

ThemeData buildTheme(AppPalette palette) {
  final Color onPrimary = _onColorFor(palette.primary);
  final Color onSecondary = _onColorFor(palette.secondary);

    final Color primaryContainer = _mix(palette.surface, palette.primary, 0.18);
    final Color secondaryContainer =
      _mix(palette.surface, palette.secondary, 0.16);
    final Color surfaceContainer = _mix(palette.surface, palette.background, 0.28);
    final Color surfaceContainerHigh =
      _mix(palette.surface, palette.border, 0.48);
    final Color surfaceContainerHighest =
      _mix(palette.surface, palette.border, 0.84);
    final Color surfaceContainerLow = _tint(palette.surface, palette.background, 0.06);

  const Color errorColor = Color(0xFFB3261E);
    final Color errorContainer = _tint(const Color(0xFFF9DEDC), palette.surface, 0.04);

  final ColorScheme colorScheme = ColorScheme(
    brightness: palette.brightness,
    primary: palette.primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: palette.text,
    secondary: palette.secondary,
    onSecondary: onSecondary,
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: palette.text,
    tertiary: palette.secondary,
    onTertiary: onSecondary,
    error: errorColor,
    onError: Colors.white,
    errorContainer: errorContainer,
    onErrorContainer: const Color(0xFF410E0B),
    surface: palette.surface,
    onSurface: palette.text,
    surfaceContainerHighest: surfaceContainerHighest,
    surfaceContainerHigh: surfaceContainerHigh,
    surfaceContainer: surfaceContainer,
    surfaceContainerLow: surfaceContainerLow,
    surfaceContainerLowest: palette.background,
    onSurfaceVariant: palette.mutedText,
    outline: palette.border,
    outlineVariant: palette.border,
    shadow: Colors.black,
    scrim: Colors.black.withValues(alpha: 0.5),
    inverseSurface: palette.text,
    onInverseSurface: palette.surface,
    inversePrimary: palette.primary,
  );

  final TextTheme baseTextTheme = GoogleFonts.spaceGroteskTextTheme(
    const TextTheme(
      displayLarge: TextStyle(fontSize: 44, fontWeight: FontWeight.w700, height: 1.1),
      displayMedium: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, height: 1.15),
      displaySmall: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, height: 1.2),
      headlineLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, height: 1.25),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.25),
      headlineSmall: TextStyle(fontSize: 19, fontWeight: FontWeight.w600, height: 1.3),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.35),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.35),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.45),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.45),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.4),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.2),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.2),
    ),
  );

  final TextTheme brandedTextTheme = baseTextTheme.copyWith(
    displayLarge: baseTextTheme.displayLarge?.copyWith(letterSpacing: -0.8),
    displayMedium: baseTextTheme.displayMedium?.copyWith(letterSpacing: -0.6),
    displaySmall: baseTextTheme.displaySmall?.copyWith(letterSpacing: -0.4),
    headlineLarge: baseTextTheme.headlineLarge?.copyWith(letterSpacing: -0.3),
    headlineMedium: baseTextTheme.headlineMedium?.copyWith(letterSpacing: -0.2),
    headlineSmall: baseTextTheme.headlineSmall?.copyWith(letterSpacing: -0.15),
  );

  final OutlineInputBorder enabledBorder = OutlineInputBorder(
    borderSide: BorderSide(color: palette.border),
    borderRadius: const BorderRadius.all(Radius.circular(_kRadiusSmall)),
  );
  final OutlineInputBorder focusedBorder = OutlineInputBorder(
    borderSide: BorderSide(color: palette.primary, width: 1.6),
    borderRadius: const BorderRadius.all(Radius.circular(_kRadiusSmall)),
  );
  final OutlineInputBorder errorBorder = OutlineInputBorder(
    borderSide: const BorderSide(color: errorColor),
    borderRadius: const BorderRadius.all(Radius.circular(_kRadiusSmall)),
  );

  final ThemeData base = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    brightness: palette.brightness,
    scaffoldBackgroundColor: palette.background,
    dividerColor: palette.border,
    splashFactory: InkSparkle.splashFactory,
    visualDensity: VisualDensity.standard,
    fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
  );

  return base.copyWith(
    textTheme: brandedTextTheme.apply(
      bodyColor: palette.text,
      displayColor: palette.text,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: palette.background,
      surfaceTintColor: Colors.transparent,
      foregroundColor: palette.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: baseTextTheme.headlineSmall?.copyWith(
        color: palette.text,
        letterSpacing: 0.2,
      ),
      iconTheme: IconThemeData(color: palette.text),
    ),
    cardTheme: CardThemeData(
      color: surfaceContainerLow,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_kRadiusMedium),
        side: BorderSide(color: _tint(palette.border, palette.primary, 0.12), width: 1.1),
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: palette.mutedText,
      textColor: palette.text,
      tileColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_kRadiusSmall),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceContainerLow,
      hintStyle: TextStyle(color: palette.mutedText),
      labelStyle: TextStyle(color: palette.mutedText),
      prefixIconColor: palette.mutedText,
      suffixIconColor: palette.mutedText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: enabledBorder,
      enabledBorder: enabledBorder,
      focusedBorder: focusedBorder,
      errorBorder: errorBorder,
      focusedErrorBorder: errorBorder,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: palette.primary,
        foregroundColor: onPrimary,
        disabledBackgroundColor: _mix(palette.border, palette.surface, 0.55),
        disabledForegroundColor: palette.mutedText,
        elevation: 0,
        minimumSize: const Size(64, 54),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
        shape: const StadiumBorder(),
        textStyle: baseTextTheme.labelLarge,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: palette.primary,
        foregroundColor: onPrimary,
        minimumSize: const Size(64, 54),
        shape: const StadiumBorder(),
        textStyle: baseTextTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: palette.text,
        side: BorderSide(color: palette.border, width: 1.4),
        minimumSize: const Size(64, 54),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
        shape: const StadiumBorder(),
        textStyle: baseTextTheme.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: palette.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_kRadiusSmall),
        ),
        textStyle: baseTextTheme.labelLarge,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: palette.mutedText,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: palette.primary,
      foregroundColor: onPrimary,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_kRadiusMedium),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceContainerHigh,
      selectedColor: primaryContainer,
      disabledColor: palette.border,
      labelStyle: baseTextTheme.labelMedium?.copyWith(color: palette.text),
      secondaryLabelStyle:
          baseTextTheme.labelMedium?.copyWith(color: palette.primary),
      side: BorderSide(color: palette.border),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_kRadiusLarge),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: palette.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_kRadiusLarge),
      ),
      titleTextStyle: baseTextTheme.titleLarge?.copyWith(color: palette.text),
      contentTextStyle:
          baseTextTheme.bodyMedium?.copyWith(color: palette.mutedText),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: palette.surface,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: palette.surface,
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(_kRadiusLarge)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: palette.text,
      contentTextStyle: TextStyle(color: palette.background),
      actionTextColor: palette.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_kRadiusSmall),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return palette.primary;
        }
        return palette.mutedText;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryContainer;
        }
        return surfaceContainerHigh;
      }),
      trackOutlineColor: WidgetStateProperty.all(palette.border),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return palette.primary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(onPrimary),
      side: BorderSide(color: palette.border, width: 1.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return palette.primary;
        }
        return palette.mutedText;
      }),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: palette.primary,
      linearTrackColor: surfaceContainerHigh,
      circularTrackColor: surfaceContainerHigh,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: palette.primary,
      unselectedLabelColor: palette.mutedText,
      indicatorColor: palette.primary,
      dividerColor: palette.border,
      labelStyle: brandedTextTheme.titleSmall,
      unselectedLabelStyle: brandedTextTheme.titleSmall,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: palette.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: primaryContainer,
      elevation: 0,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final bool selected = states.contains(WidgetState.selected);
        return baseTextTheme.labelMedium?.copyWith(
          color: selected ? palette.primary : palette.mutedText,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final bool selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? palette.primary : palette.mutedText,
        );
      }),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: palette.surface,
      surfaceTintColor: Colors.transparent,
      textStyle: baseTextTheme.bodyMedium?.copyWith(color: palette.text),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_kRadiusMedium),
        side: BorderSide(color: palette.border),
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: palette.text,
        borderRadius: BorderRadius.circular(6),
      ),
      textStyle: TextStyle(color: palette.background, fontSize: 12),
    ),
    dividerTheme: DividerThemeData(
      color: palette.border,
      thickness: 1,
      space: 1,
    ),
  );
}