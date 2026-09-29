import 'package:flutter/material.dart';

abstract final class AppColors {
  static const coral = Color(0xFFFF5263);
  static const purple = Color(0xFF7653E8);
  static const teal = Color(0xFF13B9CC);
  static const amber = Color(0xFFFFA62B);
}

ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.purple,
        brightness: brightness,
      ).copyWith(
        primary: dark ? const Color(0xFFC7B8FF) : const Color(0xFF6842CE),
        onPrimary: dark ? const Color(0xFF27164F) : Colors.white,
        secondary: dark ? const Color(0xFFFFA8AF) : const Color(0xFFC52C43),
        surface: dark ? const Color(0xFF20202D) : Colors.white,
        onSurface: dark ? const Color(0xFFF2F0FA) : const Color(0xFF252335),
        onSurfaceVariant: dark
            ? const Color(0xFFBEBACD)
            : const Color(0xFF686477),
        outlineVariant: dark
            ? const Color(0xFF3A384B)
            : const Color(0xFFECE8F3),
      );
  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  return base.copyWith(
    scaffoldBackgroundColor: dark
        ? const Color(0xFF15151F)
        : const Color(0xFFF7F6FB),
    textTheme: base.textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
