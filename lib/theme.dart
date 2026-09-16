import 'package:flutter/material.dart';

/// Jovexa Labs brand theming. Dark theme mirrors the jovexalabs.com palette:
/// near-black background #05060F with blue and cyan accents.
class JovexaTheme {
  static const Color brandBlue = Color(0xFF3B82F6);
  static const Color brandCyan = Color(0xFF22D3EE);
  static const Color darkBg = Color(0xFF05060F);
  static const Color darkSurface = Color(0xFF0C0F1D);
  static const Color darkCard = Color(0xFF12162A);
  static const Color codeBg = Color(0xFF0A0D18);
  static const Color codeBgLight = Color(0xFF1E2233);

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: brandBlue,
      brightness: Brightness.dark,
      surface: darkSurface,
    );
    return _base(scheme).copyWith(
      scaffoldBackgroundColor: darkBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
    );
  }

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: brandBlue,
      brightness: Brightness.light,
    );
    return _base(scheme).copyWith(
      scaffoldBackgroundColor: const Color(0xFFF7F8FC),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF7F8FC),
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFE3E6F0)),
        ),
      ),
    );
  }

  static ThemeData _base(ColorScheme scheme) {
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      splashFactory: InkSparkle.splashFactory,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        isDense: true,
      ),
      chipTheme: const ChipThemeData(shape: StadiumBorder()),
    );
    // Emoji fallback so course icons render everywhere, including the
    // screenshot test harness. Unknown families are skipped on devices.
    return theme.copyWith(
      textTheme: theme.textTheme.apply(
        fontFamilyFallback: const ['Segoe UI Emoji', 'Noto Color Emoji'],
      ),
    );
  }
}
