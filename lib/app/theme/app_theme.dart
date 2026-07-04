import 'package:flutter/material.dart';

/// Atmosphere Weather App — centralized theming (no state management,
/// no external packages). Colors are extracted 1:1 from the provided
/// Material 3 design tokens (light palette) with a hand-tuned dark
/// companion palette matching the "Thunderstorm" mockup.
class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------
  // LIGHT PALETTE
  // ---------------------------------------------------------------------
  static const Color _lPrimary = Color(0xFF0058BC);
  static const Color _lOnPrimary = Color(0xFFFFFFFF);
  static const Color _lPrimaryContainer = Color(0xFF0070EB);
  static const Color _lOnPrimaryContainer = Color(0xFFFEFCFF);
  static const Color _lSecondary = Color(0xFF7C5800);
  static const Color _lOnSecondary = Color(0xFFFFFFFF);
  static const Color _lSecondaryContainer = Color(0xFFFEB700);
  static const Color _lOnSecondaryContainer = Color(0xFF6B4B00);
  static const Color _lTertiary = Color(0xFFB81120);
  static const Color _lOnTertiary = Color(0xFFFFFFFF);
  static const Color _lTertiaryContainer = Color(0xFFDC3135);
  static const Color _lOnTertiaryContainer = Color(0xFFFFFBFF);
  static const Color _lError = Color(0xFFBA1A1A);
  static const Color _lOnError = Color(0xFFFFFFFF);
  static const Color _lErrorContainer = Color(0xFFFFDAD6);
  static const Color _lOnErrorContainer = Color(0xFF93000A);
  static const Color _lBackground = Color(0xFFF8F9FF);
  static const Color _lSurface = Color(0xFFF8F9FF);
  static const Color _lOnSurface = Color(0xFF0B1C30);
  static const Color _lSurfaceContainerHighest = Color(0xFFD3E4FE);
  static const Color _lOnSurfaceVariant = Color(0xFF414755);
  static const Color _lOutline = Color(0xFF717786);
  static const Color _lOutlineVariant = Color(0xFFC1C6D7);
  static const Color _lInverseSurface = Color(0xFF213145);
  static const Color _lInverseOnSurface = Color(0xFFEAF1FF);
  static const Color _lInversePrimary = Color(0xFFADC6FF);
  static const Color _lSurfaceTint = Color(0xFF005BC1);

  // Sun / weather accent tokens
  static const Color sunAccent = Color(0xFFFFBA20); // secondary-fixed-dim
  static const Color sunAccentContainer = Color(0xFFFFDEA8); // secondary-fixed

  // ---------------------------------------------------------------------
  // DARK PALETTE
  // ---------------------------------------------------------------------
  static const Color _dPrimary = Color(0xFFADC6FF);
  static const Color _dOnPrimary = Color(0xFF001A41);
  static const Color _dPrimaryContainer = Color(0xFF004493);
  static const Color _dOnPrimaryContainer = Color(0xFFD8E2FF);
  static const Color _dSecondary = Color(0xFFFFBA20);
  static const Color _dOnSecondary = Color(0xFF271900);
  static const Color _dSecondaryContainer = Color(0xFF5E4200);
  static const Color _dOnSecondaryContainer = Color(0xFFFFDEA8);
  static const Color _dTertiary = Color(0xFFFFB3AE);
  static const Color _dOnTertiary = Color(0xFF680007);
  static const Color _dTertiaryContainer = Color(0xFF930014);
  static const Color _dOnTertiaryContainer = Color(0xFFFFDAD7);
  static const Color _dError = Color(0xFFFFB4AB);
  static const Color _dOnError = Color(0xFF690005);
  static const Color _dErrorContainer = Color(0xFF93000A);
  static const Color _dOnErrorContainer = Color(0xFFFFDAD6);
  static const Color _dBackground = Color(0xFF0B1521);
  static const Color _dSurface = Color(0xFF0B1521);
  static const Color _dOnSurface = Color(0xFFEAF1FF);
  static const Color _dSurfaceContainerHighest = Color(0xFF2C3745);
  static const Color _dOnSurfaceVariant = Color(0xFFC1C6D7);
  static const Color _dOutline = Color(0xFF8B92A3);
  static const Color _dOutlineVariant = Color(0xFF414755);
  static const Color _dInverseSurface = Color(0xFFEAF1FF);
  static const Color _dInverseOnSurface = Color(0xFF213145);
  static const Color _dInversePrimary = Color(0xFF0058BC);
  static const Color _dSurfaceTint = Color(0xFFADC6FF);

  static String backgroundAsset(Brightness brightness) {
    return brightness == Brightness.dark
        ? 'assets/images/dark.png'
        : 'assets/images/light.png';
  }

  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 24;
  static const double radiusXl = 28;
  static const double gutter = 16;
  static const double cardGap = 12;
  static const double sectionMargin = 40;

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: _lPrimary,
      onPrimary: _lOnPrimary,
      primaryContainer: _lPrimaryContainer,
      onPrimaryContainer: _lOnPrimaryContainer,
      secondary: _lSecondary,
      onSecondary: _lOnSecondary,
      secondaryContainer: _lSecondaryContainer,
      onSecondaryContainer: _lOnSecondaryContainer,
      tertiary: _lTertiary,
      onTertiary: _lOnTertiary,
      tertiaryContainer: _lTertiaryContainer,
      onTertiaryContainer: _lOnTertiaryContainer,
      error: _lError,
      onError: _lOnError,
      errorContainer: _lErrorContainer,
      onErrorContainer: _lOnErrorContainer,
      surface: _lSurface,
      onSurface: _lOnSurface,
      surfaceContainerHighest: _lSurfaceContainerHighest,
      onSurfaceVariant: _lOnSurfaceVariant,
      outline: _lOutline,
      outlineVariant: _lOutlineVariant,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: _lInverseSurface,
      onInverseSurface: _lInverseOnSurface,
      inversePrimary: _lInversePrimary,
      surfaceTint: _lSurfaceTint,
    );
    return _buildTheme(colorScheme: colorScheme, background: _lBackground);
  }

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: _dPrimary,
      onPrimary: _dOnPrimary,
      primaryContainer: _dPrimaryContainer,
      onPrimaryContainer: _dOnPrimaryContainer,
      secondary: _dSecondary,
      onSecondary: _dOnSecondary,
      secondaryContainer: _dSecondaryContainer,
      onSecondaryContainer: _dOnSecondaryContainer,
      tertiary: _dTertiary,
      onTertiary: _dOnTertiary,
      tertiaryContainer: _dTertiaryContainer,
      onTertiaryContainer: _dOnTertiaryContainer,
      error: _dError,
      onError: _dOnError,
      errorContainer: _dErrorContainer,
      onErrorContainer: _dOnErrorContainer,
      surface: _dSurface,
      onSurface: _dOnSurface,
      surfaceContainerHighest: _dSurfaceContainerHighest,
      onSurfaceVariant: _dOnSurfaceVariant,
      outline: _dOutline,
      outlineVariant: _dOutlineVariant,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: _dInverseSurface,
      onInverseSurface: _dInverseOnSurface,
      inversePrimary: _dInversePrimary,
      surfaceTint: _dSurfaceTint,
    );
    return _buildTheme(colorScheme: colorScheme, background: _dBackground);
  }

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Color background,
  }) {
    final baseTextTheme = ThemeData(brightness: colorScheme.brightness).textTheme;
    final textTheme = baseTextTheme.copyWith(
      displayLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 96,
        height: 100 / 96,
        letterSpacing: -0.04 * 96,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 32,
        height: 40 / 32,
        letterSpacing: -0.02 * 32,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        height: 16 / 12,
        letterSpacing: 0.05 * 12,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurfaceVariant,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'Inter',
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: colorScheme.onPrimaryContainer,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }
}