import 'package:flutter/material.dart';

/// Premium color palette for Zeni ride-hailing platform
/// Designed with Material Design 3 principles and premium aesthetic
class PremiumColors {
  PremiumColors._();

  static const light = PremiumColorsLight._();
  static const dark = PremiumColorsDark._();
  static const gradients = PremiumGradients._();

  // ========== SHADOW DEFINITIONS ==========
  static const BoxShadow shadowSM = BoxShadow(
    color: Color(0x14000000), // Increased opacity
    blurRadius: 4, // Increased
    offset: Offset(0, 2), // Increased
  );

  static const BoxShadow shadowMD = BoxShadow(
    color: Color(0x1E000000), // Increased opacity
    blurRadius: 8, // Increased
    offset: Offset(0, 4), // Increased
  );

  static const BoxShadow shadowLG = BoxShadow(
    color: Color(0x28000000), // Increased opacity
    blurRadius: 16, // Increased
    offset: Offset(0, 8), // Increased
  );

  static const BoxShadow shadowXL = BoxShadow(
    color: Color(0x32000000), // Increased opacity
    blurRadius: 24, // Increased
    offset: Offset(0, 12), // Increased
  );
}

class PremiumColorsLight {
  const PremiumColorsLight._();

  // Primary: Sophisticated indigo gradient base (Deepened)
  final Color primary = const Color(0xFF4F46E5); // Indigo-600
  final Color primaryDark = const Color(0xFF4338CA); // Indigo-700
  final Color primaryLight = const Color(0xFFE0E7FF); // Indigo-100

  // Secondary: Rich teal accent (Deepened)
  final Color secondary = const Color(0xFF0D9488); // Teal-600
  final Color secondaryDark = const Color(0xFF0F766E); // Teal-700
  final Color secondaryLight = const Color(0xFFCCFBF1); // Teal-100

  // Tertiary: Warm amber for highlights
  final Color tertiary = const Color(0xFFF59E0B); // Amber-500
  final Color tertiaryDark = const Color(0xFFD97706); // Amber-600
  final Color tertiaryLight = const Color(0xFFFEF3C7); // Amber-100

  // Neutral: Professional grays
  final Color background = const Color(0xFFFAFAFA); // Gray-50
  final Color surface = const Color(0xFFFFFFFF); // White
  final Color surfaceVariant = const Color(0xFFF3F4F6); // Gray-100
  final Color outline = const Color(0xFFD1D5DB); // Gray-300
  final Color outlineVariant = const Color(0xFFE5E7EB); // Gray-200

  // Text: High contrast
  final Color onPrimary = const Color(0xFFFFFFFF); // White
  final Color onSecondary = const Color(0xFFFFFFFF); // White
  final Color onBackground = const Color(0xFF1F2937); // Gray-800
  final Color onSurface = const Color(0xFF1F2937); // Gray-800
  final Color onSurfaceVariant = const Color(0xFF6B7280); // Gray-500

  // Semantic colors
  final Color success = const Color(0xFF10B981); // Emerald-500
  final Color warning = const Color(0xFFF59E0B); // Amber-500
  final Color error = const Color(0xFFEF4444); // Red-500
  final Color info = const Color(0xFF3B82F6); // Blue-500

  // Grays for hierarchy
  final Color textPrimary = const Color(0xFF111827); // Gray-900
  final Color textSecondary = const Color(0xFF6B7280); // Gray-500
  final Color textTertiary = const Color(0xFF9CA3AF); // Gray-400
  final Color textDisabled = const Color(0xFFD1D5DB); // Gray-300

  // Divider
  final Color divider = const Color(0xFFE5E7EB); // Gray-200

  // Overlay
  final Color overlay = const Color(0x0D000000); // Black 5%
}

class PremiumColorsDark {
  const PremiumColorsDark._();

  // Primary: Bright indigo for visibility (Brightened)
  final Color primary = const Color(0xFF6366F1); // Indigo-500
  final Color primaryDark = const Color(0xFF818CF8); // Indigo-400
  final Color primaryLight = const Color(0xFF4F46E5); // Indigo-600

  // Secondary: Vibrant teal (Brightened)
  final Color secondary = const Color(0xFF14B8A6); // Teal-500
  final Color secondaryDark = const Color(0xFF2DD4BF); // Teal-400
  final Color secondaryLight = const Color(0xFF0D9488); // Teal-600

  // Tertiary: Bright amber
  final Color tertiary = const Color(0xFFFBBF24); // Amber-400
  final Color tertiaryDark = const Color(0xFFF59E0B); // Amber-500
  final Color tertiaryLight = const Color(0xFFD97706); // Amber-600

  // Neutral: Dark mode grays
  final Color background = const Color(0xFF0F172A); // Slate-900
  final Color surface = const Color(0xFF1E293B); // Slate-800
  final Color surfaceVariant = const Color(0xFF334155); // Slate-700
  final Color outline = const Color(0xFF475569); // Slate-600
  final Color outlineVariant = const Color(0xFF64748B); // Slate-500

  // Text: High contrast for dark
  final Color onPrimary = const Color(0xFF0F172A); // Slate-900
  final Color onSecondary = const Color(0xFF0F172A); // Slate-900
  final Color onBackground = const Color(0xFFF1F5F9); // Slate-100
  final Color onSurface = const Color(0xFFE2E8F0); // Slate-200
  final Color onSurfaceVariant = const Color(0xFFCBD5E1); // Slate-300

  // Semantic colors (adjusted for dark mode)
  final Color success = const Color(0xFF34D399); // Emerald-400
  final Color warning = const Color(0xFFFBBF24); // Amber-400
  final Color error = const Color(0xFFF87171); // Red-400
  final Color info = const Color(0xFF60A5FA); // Blue-400

  // Text hierarchy for dark
  final Color textPrimary = const Color(0xFFF8FAFC); // Slate-50
  final Color textSecondary = const Color(0xFFCBD5E1); // Slate-300
  final Color textTertiary = const Color(0xFF94A3B8); // Slate-400
  final Color textDisabled = const Color(0xFF64748B); // Slate-500

  // Divider
  final Color divider = const Color(0xFF334155); // Slate-700

  // Overlay
  final Color overlay = const Color(0x1AFFFFFF); // White 10%
}

class PremiumGradients {
  const PremiumGradients._();

  // Primary gradient
  final LinearGradient gradient1 = const LinearGradient(
    colors: [
      Color(0xFF818CF8), // Indigo-400
      Color(0xFF6366F1), // Indigo-500
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Secondary gradient (cool)
  final LinearGradient gradient2 = const LinearGradient(
    colors: [
      Color(0xFF2DD4BF), // Teal-400
      Color(0xFF14B8A6), // Teal-500
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Warning gradient
  final LinearGradient gradient3 = const LinearGradient(
    colors: [
      Color(0xFFFBBF24), // Amber-400
      Color(0xFFF59E0B), // Amber-500
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Premium dark gradient
  final LinearGradient gradient4 = const LinearGradient(
    colors: [
      Color(0xFF1E293B), // Slate-800
      Color(0xFF0F172A), // Slate-900
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
