import 'package:flutter/material.dart';

abstract final class SiagaColors {
  static const navy = Color(0xFF1E3A8A);
  static const navyHover = Color(0xFF1E40AF);
  static const danger = Color(0xFFDC2626);
  static const warning = Color(0xFFD97706);
  static const safe = Color(0xFF059669);
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);
}

abstract final class SiagaTheme {
  static ThemeData get light {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: SiagaColors.navy,
          brightness: Brightness.light,
        ).copyWith(
          primary: SiagaColors.navy,
          secondary: SiagaColors.navyHover,
          error: SiagaColors.danger,
          surface: SiagaColors.surface,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: SiagaColors.background,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: SiagaColors.ink,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          color: SiagaColors.ink,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          height: 1.25,
        ),
        titleLarge: TextStyle(
          color: SiagaColors.ink,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: SiagaColors.ink,
          fontSize: 15,
          height: 1.55,
        ),
        bodyMedium: TextStyle(
          color: SiagaColors.muted,
          fontSize: 14,
          height: 1.55,
        ),
      ),
    );
  }
}
