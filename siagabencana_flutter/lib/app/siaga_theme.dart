import 'package:flutter/material.dart';

/// Centralized color tokens for SiagaBencana's Modern Professional design system.
///
/// Built around authoritative deep navy, calm neutral surfaces, and disciplined
/// semantic accents for disaster readiness and public-safety clarity.
abstract final class SiagaColors {
  // Brand & primary identity
  static const navy = Color(0xFF0F294A);
  static const navyDeep = Color(0xFF0A1D36);
  static const navyHover = Color(0xFF1D4ED8);
  static const primaryBlue = Color(0xFF1D4ED8);
  static const primarySoft = Color(0xFFEFF6FF);
  static const primaryBorder = Color(0xFFBFDBFE);

  // Semantic statuses
  static const danger = Color(0xFFDC2626);
  static const dangerSoft = Color(0xFFFEF2F2);
  static const dangerBorder = Color(0xFFFECACA);
  static const dangerText = Color(0xFF991B1B);

  static const warning = Color(0xFFD97706);
  static const warningSoft = Color(0xFFFFFBEB);
  static const warningBorder = Color(0xFFFDE68A);
  static const warningText = Color(0xFF92400E);

  static const safe = Color(0xFF059669);
  static const safeSoft = Color(0xFFECFDF5);
  static const safeBorder = Color(0xFFA7F3D0);
  static const safeText = Color(0xFF065F46);

  static const info = Color(0xFF0284C7);
  static const infoSoft = Color(0xFFF0F9FF);
  static const infoBorder = Color(0xFFBAE6FD);
  static const infoText = Color(0xFF075985);

  // Neutral canvas, surfaces & hairlines
  static const background = Color(0xFFF5F7FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSubtle = Color(0xFFF8FAFC);
  static const surfaceMuted = Color(0xFFF1F5F9);
  static const border = Color(0xFFE2E8F0);
  static const borderStrong = Color(0xFFCBD5E1);

  // Typography hierarchy
  static const ink = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF334155);
  static const muted = Color(0xFF64748B);
  static const textSubtle = Color(0xFF94A3B8);

  // Legacy aliases retained for full compatibility across modules
  static const textDark = ink;
  static const textMuted = muted;
}

/// Standardized spacing rhythm (4pt scale).
abstract final class SiagaSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double section = 36;
}

/// Consistent, moderate border radii — avoiding overly bubbly surfaces.
abstract final class SiagaRadius {
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double pill = 999;
}

/// Restrained elevation shadows for subtle depth on clean bordered surfaces.
abstract final class SiagaShadows {
  static const List<BoxShadow> subtle = [
    BoxShadow(color: Color(0x0A0F172A), blurRadius: 3, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x080F172A), blurRadius: 8, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x050F172A), blurRadius: 2, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> hover = [
    BoxShadow(color: Color(0x120F172A), blurRadius: 16, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x060F172A), blurRadius: 3, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(color: Color(0x180F172A), blurRadius: 20, offset: Offset(0, 8)),
  ];
}

/// Responsive layout breakpoints.
abstract final class SiagaBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1080;
  static const double maxContentWidth = 1360;

  static double pageHorizontalPadding(double width) {
    if (width < mobile) return 16;
    if (width < desktop) return 24;
    return 32;
  }
}

abstract final class SiagaTheme {
  static const String _fontFamily = 'Plus Jakarta Sans';
  static const List<String> _fontFallbacks = [
    'Inter',
    'Segoe UI',
    'Roboto',
    'sans-serif',
  ];

  static TextStyle _text({
    required double size,
    required FontWeight weight,
    required Color color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontFamilyFallback: _fontFallbacks,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static ThemeData get light {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: SiagaColors.navy,
          brightness: Brightness.light,
        ).copyWith(
          primary: SiagaColors.navy,
          onPrimary: Colors.white,
          primaryContainer: SiagaColors.primarySoft,
          onPrimaryContainer: SiagaColors.navy,
          secondary: SiagaColors.primaryBlue,
          onSecondary: Colors.white,
          secondaryContainer: SiagaColors.primarySoft,
          onSecondaryContainer: SiagaColors.navy,
          error: SiagaColors.danger,
          onError: Colors.white,
          surface: SiagaColors.surface,
          onSurface: SiagaColors.ink,
          surfaceContainerHighest: SiagaColors.surfaceMuted,
          outline: SiagaColors.border,
          outlineVariant: SiagaColors.border,
        );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(SiagaRadius.md),
      borderSide: const BorderSide(color: SiagaColors.borderStrong),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: _fontFamily,
      fontFamilyFallback: _fontFallbacks,
      scaffoldBackgroundColor: SiagaColors.background,
      splashFactory: InkRipple.splashFactory,
      dividerTheme: const DividerThemeData(
        color: SiagaColors.border,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: SiagaColors.surface,
        foregroundColor: SiagaColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: _text(
          size: 17,
          weight: FontWeight.w700,
          color: SiagaColors.ink,
          letterSpacing: -0.2,
        ),
        shape: const Border(bottom: BorderSide(color: SiagaColors.border)),
      ),
      textTheme: TextTheme(
        displaySmall: _text(
          size: 32,
          weight: FontWeight.w700,
          color: SiagaColors.ink,
          height: 1.18,
          letterSpacing: -0.6,
        ),
        headlineLarge: _text(
          size: 28,
          weight: FontWeight.w700,
          color: SiagaColors.ink,
          height: 1.22,
          letterSpacing: -0.5,
        ),
        headlineMedium: _text(
          size: 20,
          weight: FontWeight.w700,
          color: SiagaColors.ink,
          height: 1.3,
          letterSpacing: -0.3,
        ),
        headlineSmall: _text(
          size: 18,
          weight: FontWeight.w700,
          color: SiagaColors.ink,
          height: 1.35,
          letterSpacing: -0.2,
        ),
        titleLarge: _text(
          size: 16,
          weight: FontWeight.w700,
          color: SiagaColors.ink,
          height: 1.35,
          letterSpacing: -0.15,
        ),
        titleMedium: _text(
          size: 15,
          weight: FontWeight.w600,
          color: SiagaColors.ink,
          height: 1.4,
        ),
        titleSmall: _text(
          size: 13.5,
          weight: FontWeight.w600,
          color: SiagaColors.ink,
          height: 1.4,
        ),
        bodyLarge: _text(
          size: 15,
          weight: FontWeight.w400,
          color: SiagaColors.textSecondary,
          height: 1.6,
        ),
        bodyMedium: _text(
          size: 14,
          weight: FontWeight.w400,
          color: SiagaColors.muted,
          height: 1.55,
        ),
        bodySmall: _text(
          size: 12.5,
          weight: FontWeight.w500,
          color: SiagaColors.muted,
          height: 1.45,
        ),
        labelLarge: _text(
          size: 14,
          weight: FontWeight.w600,
          color: SiagaColors.ink,
          letterSpacing: 0.1,
        ),
        labelMedium: _text(
          size: 12.5,
          weight: FontWeight.w600,
          color: SiagaColors.textSecondary,
          letterSpacing: 0.15,
        ),
        labelSmall: _text(
          size: 11,
          weight: FontWeight.w700,
          color: SiagaColors.muted,
          letterSpacing: 0.6,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: SiagaColors.navy,
          foregroundColor: Colors.white,
          disabledBackgroundColor: SiagaColors.surfaceMuted,
          disabledForegroundColor: SiagaColors.textSubtle,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SiagaRadius.md),
          ),
          textStyle: _text(
            size: 14,
            weight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SiagaColors.navy,
          disabledForegroundColor: SiagaColors.textSubtle,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          side: const BorderSide(color: SiagaColors.borderStrong),
          backgroundColor: SiagaColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SiagaRadius.md),
          ),
          textStyle: _text(
            size: 14,
            weight: FontWeight.w600,
            color: SiagaColors.navy,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: SiagaColors.primaryBlue,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SiagaRadius.md),
          ),
          textStyle: _text(
            size: 13.5,
            weight: FontWeight.w600,
            color: SiagaColors.primaryBlue,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SiagaColors.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        labelStyle: _text(
          size: 13.5,
          weight: FontWeight.w500,
          color: SiagaColors.muted,
        ),
        hintStyle: _text(
          size: 13.5,
          weight: FontWeight.w400,
          color: SiagaColors.textSubtle,
        ),
        floatingLabelStyle: _text(
          size: 13,
          weight: FontWeight.w600,
          color: SiagaColors.navy,
        ),
        errorStyle: _text(
          size: 12,
          weight: FontWeight.w500,
          color: SiagaColors.danger,
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: const BorderSide(
            color: SiagaColors.primaryBlue,
            width: 1.6,
          ),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: SiagaColors.danger),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: SiagaColors.danger, width: 1.6),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: SiagaColors.surface,
        selectedColor: SiagaColors.navy,
        disabledColor: SiagaColors.surfaceMuted,
        side: const BorderSide(color: SiagaColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SiagaRadius.md),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        labelStyle: _text(
          size: 13,
          weight: FontWeight.w600,
          color: SiagaColors.textSecondary,
        ),
        secondaryLabelStyle: _text(
          size: 13,
          weight: FontWeight.w600,
          color: Colors.white,
        ),
        checkmarkColor: Colors.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: SiagaColors.surface,
        elevation: 0,
        height: 66,
        surfaceTintColor: Colors.transparent,
        indicatorColor: SiagaColors.primarySoft,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected ? SiagaColors.navy : SiagaColors.muted,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return _text(
            size: 11.5,
            weight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? SiagaColors.navy : SiagaColors.muted,
          );
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: SiagaColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SiagaRadius.xl),
          side: const BorderSide(color: SiagaColors.border),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: SiagaColors.ink,
        contentTextStyle: _text(
          size: 13.5,
          weight: FontWeight.w500,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SiagaRadius.md),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: SiagaColors.primaryBlue,
        linearTrackColor: SiagaColors.border,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: SiagaColors.ink,
          borderRadius: BorderRadius.circular(SiagaRadius.sm),
        ),
        textStyle: _text(
          size: 12,
          weight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}
