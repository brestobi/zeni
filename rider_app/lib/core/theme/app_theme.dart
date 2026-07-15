import 'package:flutter/material.dart';
import 'package:zeni_utilities/zeni_utilities.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final colors = PremiumColors.light;
    final textTheme = PremiumTypography.lightTextTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        secondary: colors.secondary,
        onSecondary: colors.onSecondary,
        tertiary: colors.tertiary,
        surface: colors.surface,
        onSurface: colors.onSurface,
        onSurfaceVariant: colors.onSurfaceVariant,
        surfaceContainerHighest: colors.surfaceVariant,
        error: colors.error,
        outline: colors.outline,
      ),
      scaffoldBackgroundColor: colors.background,
      textTheme: textTheme,
      
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          minimumSize: const Size(double.infinity, 54),
          elevation: 4, // Increased
          shadowColor: colors.primary.withValues(alpha: 0.5), // Increased contrast
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Tighter radius
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700, // Bolder
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary, width: 2), // Thicker border
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Tighter radius
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700, // Bolder
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Tighter radius
          borderSide: BorderSide(color: colors.outline, width: 1.5), // Thicker/Darker
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Tighter radius
          borderSide: BorderSide(color: colors.outline, width: 1.5), // Thicker/Darker
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Tighter radius
          borderSide: BorderSide(color: colors.primary, width: 2.5), // Thicker
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Tighter radius
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Tighter radius
          borderSide: BorderSide(color: colors.error, width: 2.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        hintStyle: TextStyle(color: colors.textTertiary),
        labelStyle: TextStyle(color: colors.textSecondary),
      ),
      
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 8, // Increased
        shadowColor: Colors.black.withValues(alpha: 0.15), // Darker shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14), // Tighter radius
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colors = PremiumColors.dark;
    final textTheme = PremiumTypography.darkTextTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        secondary: colors.secondary,
        onSecondary: colors.onSecondary,
        tertiary: colors.tertiary,
        surface: colors.surface,
        onSurface: colors.onSurface,
        onSurfaceVariant: colors.onSurfaceVariant,
        surfaceContainerHighest: colors.surfaceVariant,
        error: colors.error,
        outline: colors.outline,
      ),
      scaffoldBackgroundColor: colors.background,
      textTheme: textTheme,
      
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          minimumSize: const Size(double.infinity, 54),
          elevation: 4, // Increased
          shadowColor: colors.primary.withValues(alpha: 0.5), // Increased contrast
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Tighter radius
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700, // Bolder
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary, width: 2), // Thicker border
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Tighter radius
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700, // Bolder
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Tighter radius
          borderSide: BorderSide(color: colors.outline, width: 1.5), // Thicker/Darker
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Tighter radius
          borderSide: BorderSide(color: colors.outline, width: 1.5), // Thicker/Darker
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Tighter radius
          borderSide: BorderSide(color: colors.primary, width: 2.5), // Thicker
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Tighter radius
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Tighter radius
          borderSide: BorderSide(color: colors.error, width: 2.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        hintStyle: TextStyle(color: colors.textTertiary),
        labelStyle: TextStyle(color: colors.textSecondary),
      ),
      
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 8, // Increased
        shadowColor: Colors.black.withValues(alpha: 0.4), // Darker shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14), // Tighter radius
        ),
      ),
    );
  }
}
