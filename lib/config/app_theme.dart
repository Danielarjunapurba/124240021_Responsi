import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ubah palet warna di bawah atau ubah [useDarkMode] menjadi `true` untuk
class AppTheme {
  AppTheme._();

  static const bool useDarkMode = false;

  static const Color primaryColor = Color(0xFF2563EB);
  static const Color primaryLightColor = Color(0xFF60A5FA);
  static const Color secondaryColor = Color(0xFF0F172A);
  static const Color accentColor = Color(0xFFF97316);

  static const Color lightBackground = Color(0xFFF4F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFEEF2F6);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);

  static const Color darkBackground = Color(0xFF0B1120);
  static const Color darkSurface = Color(0xFF111C33);
  static const Color darkSurfaceMuted = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF26354D);

  static const Color successColor = Color(0xFF10B981);
  static const Color dangerColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);

  static LinearGradient get heroGradient => const LinearGradient(
    colors: [primaryColor, primaryLightColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get brandGradient => const LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static List<BoxShadow> softShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.28)
            : const Color(0xFF0F172A).withValues(alpha: 0.055),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ];
  }

  static Color adaptiveBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBorder
        : lightBorder;
  }

  static Color adaptiveMutedSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurfaceMuted
        : lightSurfaceMuted;
  }

  static Color statusColor(String status) {
    final normalized = status.trim().toLowerCase();
    if (normalized == 'alive' ||
        normalized == 'active' ||
        normalized == 'available' ||
        normalized == 'published' ||
        normalized == 'in stock') {
      return successColor;
    }
    if (normalized == 'dead' ||
        normalized == 'inactive' ||
        normalized == 'unavailable' ||
        normalized == 'cancelled' ||
        normalized == 'out of stock') {
      return dangerColor;
    }
    if (normalized == 'low stock') return warningColor;
    return warningColor;
  }

  /// Tema aktif awal berdasarkan flag [useDarkMode].
  static ThemeData get activeTheme => useDarkMode ? darkTheme : lightTheme;

  static ThemeData get lightTheme => _buildTheme(
    brightness: Brightness.light,
    background: lightBackground,
    surface: lightSurface,
    textPrimary: lightTextPrimary,
    textSecondary: lightTextSecondary,
    borderColor: lightBorder,
    navIndicatorAlpha: 0.14,
  );

  static ThemeData get darkTheme => _buildTheme(
    brightness: Brightness.dark,
    background: darkBackground,
    surface: darkSurface,
    textPrimary: darkTextPrimary,
    textSecondary: darkTextSecondary,
    borderColor: darkBorder,
    navIndicatorAlpha: 0.24,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color textPrimary,
    required Color textSecondary,
    required Color borderColor,
    required double navIndicatorAlpha,
  }) {
    final baseTheme = ThemeData(brightness: brightness, useMaterial3: true);
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: isDark ? primaryLightColor : primaryColor,
      secondary: secondaryColor,
      surface: surface,
      error: dangerColor,
      brightness: brightness,
    );

    return baseTheme.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: _buildTextTheme(baseTheme.textTheme, textPrimary),
      dividerColor: borderColor,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? darkSurfaceMuted : const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: dangerColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: dangerColor, width: 1.8),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: textSecondary,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: borderColor),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.primary.withValues(
          alpha: navIndicatorAlpha,
        ),
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? colorScheme.primary : textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected ? colorScheme.primary : textSecondary,
          );
        }),
      ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base, Color textColor) {
    TextStyle? applyFont(TextStyle? style) {
      if (style == null) return null;
      return GoogleFonts.plusJakartaSans(textStyle: style, color: textColor);
    }

    return base.copyWith(
      displayLarge: applyFont(base.displayLarge),
      displayMedium: applyFont(base.displayMedium),
      displaySmall: applyFont(base.displaySmall),
      headlineLarge: applyFont(base.headlineLarge),
      headlineMedium: applyFont(base.headlineMedium),
      headlineSmall: applyFont(base.headlineSmall),
      titleLarge: applyFont(base.titleLarge),
      titleMedium: applyFont(base.titleMedium),
      titleSmall: applyFont(base.titleSmall),
      bodyLarge: applyFont(base.bodyLarge),
      bodyMedium: applyFont(base.bodyMedium),
      bodySmall: applyFont(base.bodySmall),
      labelLarge: applyFont(base.labelLarge),
      labelMedium: applyFont(base.labelMedium),
      labelSmall: applyFont(base.labelSmall),
    );
  }
}
